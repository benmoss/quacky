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

  class Double
    def initialize(name)
      @name = name
    end

    def inspect
      "<Quacky::Double :#{name}>"
    end

    private
    attr_reader :name
  end

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

    def quacky_expectations
      @expectations ||= {}
    end

    def setup_expectation method_name
      method_name = method_name.to_sym
      raise Quacky::NoMethodError unless respond_to? method_name

      quacky_expectations[method_name] = Stub.new(public_method(method_name))
      sanitized_name, postpend = parse_method_name method_name

      eval <<-EVAL
        class << self
          define_method("#{sanitized_name}_with_expectation#{postpend}") do |*args|
            quacky_expectations[:#{method_name}].call *args
          end

          alias_method_chain :#{method_name}, :expectation
        end
      EVAL

      quacky_expectations[method_name]
    end

    def parse_method_name method_name
      method_name = method_name.to_s
      eol_matcher = /([\!\?])$/
      method_name_postpend = method_name.to_s.match(eol_matcher) ? $1 : ""
      method_name_minus_postpend = method_name.to_s.gsub eol_matcher, ""
      [method_name_minus_postpend, method_name_postpend]
    end
  end

  def double(name, *duck_types)
    Double.new(name).tap do |object|
      duck_types.each do |duck_type|
        object.extend duck_type
      end
      object.extend Quacky::Expectations
    end
  end

  module ClassInspect
    attr_reader :class_double_name

    def name_class_double name
      @class_double_name = name
    end

    def inspect
      "Quacky::ClassDouble(:#{@class_double_name})"
    end
  end

  module InstanceInspect
    def inspect
      "<Quacky::ClassDouble :#{self.class.class_double_name}>"
    end
  end

  def class_double name, options
    class_modules, instance_modules = parse_class_double_options options

    Class.new do
      extend ClassInspect
      include InstanceInspect
      name_class_double name

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
