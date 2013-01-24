module Quacky
  class DuckTypeVerificationFailure < RuntimeError; end

  class DuckTypeVerifier
    def initialize duck_type
      @duck_type = duck_type
    end

    def verify! object
      duck_type_methods.each do |method|
        raise Quacky::DuckTypeVerificationFailure, "object does not respond to `#{method.name}'" unless object.respond_to?(method.name)

        begin
          target_method = object.public_method(method.name)
          return true if target_method.parameters.any? { |p| p.first == :rest }

          method_parameters = method.parameters.reject { |p| p.first == :block }
          target_method_parameters = target_method.parameters.reject { |p| p.first == :block }

          if target_method_parameters.count != method_parameters.count ||
             target_method_parameters.map {|p| p.first } != method_parameters.map {|p| p.first}
            raise Quacky::DuckTypeVerificationFailure, "definitions of method `#{method.name}` differ in parameters accepted."
          end
        rescue NameError; end

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
