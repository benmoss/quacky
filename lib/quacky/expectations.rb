require 'active_support/core_ext/module/aliasing'

module Quacky
  class NoMethodError < RuntimeError; end

  module Expectations
    def quacky_stub method_name
      setup_expectation method_name
    end

    def should_receive method_name
      quacky_stub(method_name).tap do |expectation|
        Quacky.expectations << expectation
      end
    end

    private

    def quacky_expectations
      @expectations ||= {}
    end

    def setup_expectation method_name
      method_name = method_name.to_sym
      raise Quacky::NoMethodError, "#{inspect} does not define `#{method_name}'" unless respond_to?(method_name)

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
end
