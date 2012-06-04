require 'active_support/core_ext/module/aliasing'

module Quacky
  extend self
  class Double; end

  class NoMethodError < RuntimeError; end
  class MethodSignatureMismatch < ArgumentError; end

  class MessageExpectation
    def initialize(method)
      @method = method
    end

    def with(*args)
      @expected_args = args
      call_through *args
    end

    def and_return(value=nil, &block)
      @return_value = value
      @return_block = block
    end

    def call(*args)
      @called_args = args
      call_through *args
      return_value
    end

    def satisfied?
      if expected_args
        called_args == expected_args
      else
        !!called_args
      end
    end

    private
    attr_reader :called_args, :expected_args

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
      raise Quacky::NoMethodError unless respond_to? method_name
      instance_variable_set "@#{method_name}_expectation", MessageExpectation.new(public_method(method_name))

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
