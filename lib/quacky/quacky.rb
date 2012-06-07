require 'active_support/core_ext/module/aliasing'

module Quacky
  class DuckTypeVerificationFailure < RuntimeError; end

  class DuckTypeVerifier
    def initialize duck_type
      @duck_type = duck_type
    end

    def verify!(object)
      duck_type_methods.each do |method|
        raise Quacky::DuckTypeVerificationFailure, "object does not respond to `#{method.name}'" unless object.respond_to?(method.name)

        target_method = object.public_method(method.name)
        if target_method.parameters.count != method.parameters.count ||
           target_method.parameters.map {|p| p.first } != method.parameters.map {|p| p.first}
          raise Quacky::DuckTypeVerificationFailure, "method signatures differ"
        end

        true
      end
    end

    private
    attr_reader :duck_type

    def duck_type_methods
      @duck_type_methods ||= (duck_type_object.methods - Object.methods).map do |method_name|
        @duck_type_object.public_method(method_name)
      end
    end

    def duck_type_object
      return @duck_type_object if @duck_type_object 
      duck_type_class = Class.new
      duck_type_class.send :include, duck_type
      @duck_type_object = duck_type_class.new
    end
  end
end

module Quacky
  extend self
  class Double; end

  class NoMethodError < RuntimeError;             end
  class MethodSignatureMismatch < ArgumentError;  end
  class UnexpectedArguments < ArgumentError;      end
  class UnsatisfiedExpectation < ArgumentError;      end

  def expectations
    @expectations ||= []
  end

  def clear_expectations!
    @expectations = nil
  end

  class Stub
    def initialize method
      @method = method
    end

    def with *args
      @expected_args = args
      call_through *args
      self
    end

    def and_return value=nil, &block
      @return_value = value
      @return_block = block
    end

    def call *args
      @called_args = args
      validate_expectation
      call_through *args

      if expected_args
        return_value if (called_args == expected_args)
      else
        return_value
      end
    end

    def validate_satisfaction!
      if expected_args 
        if called_args == expected_args
          true
        else
          raise UnsatisfiedExpectation
        end
      else
        was_called? || raise(UnsatisfiedExpectation)
      end
    end

    private
    attr_reader :called_args, :expected_args

    def was_called?
      !!called_args
    end

    def validate_expectation
      if expected_args && called_args != expected_args
        raise(
          Quacky::UnexpectedArguments, 
          "#{@method.name} was called with unexpected arguments: #{called_args.join ", "}"
        )
      end
    end

    def return_value
      return @return_value if @return_value
      @return_block.call if @return_block
    end

    def call_through *args
      begin
        @method.call *args
      rescue ArgumentError => e
        raise Quacky::MethodSignatureMismatch, e.message
      end
    end
  end

  module Expectations
    def stub method_name
      setup_expectation method_name
    end

    def should_receive method_name
      stub(method_name).tap do |expectation|
        Quacky.expectations << expectation
      end
    end

    private
    def setup_expectation method_name
      raise Quacky::NoMethodError unless respond_to? method_name
      instance_variable_set "@#{method_name}_expectation", Stub.new(public_method(method_name))

      eval <<-EVAL
        class << self
          define_method("#{method_name}_with_expectation") do |*args|
            @#{method_name}_expectation.call *args
          end

          alias_method_chain :#{method_name}, :expectation
        end
      EVAL

      instance_variable_get "@#{method_name}_expectation"
    end
  end

  def double duck_type
    Double.new.tap do |object|
      object.extend duck_type
      object.extend Quacky::Expectations
    end
  end

  def class_double options
    class_modules, instance_modules = parse_class_double_options options

    Class.new do
      class_modules.each do |class_module|
        extend class_module
      end

      instance_modules.each do |instance_module|
        include instance_module
      end
    end
  end

  private
  def parse_class_double_options options
    class_modules    = options.fetch :class
    instance_modules = options.fetch :instance

    class_modules    = [class_modules] unless class_modules.respond_to? :each
    instance_modules = [instance_modules] unless instance_modules.respond_to? :each

    [class_modules, instance_modules]
  end
end
