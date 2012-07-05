module Quacky
  class DuckTypeVerificationFailure < RuntimeError; end

  class DuckTypeVerifier
    def initialize duck_type
      @duck_type = duck_type
    end

    def verify! object
      duck_type_methods.each do |method|
        raise Quacky::DuckTypeVerificationFailure, "object does not respond to `#{method.name}'" unless object.respond_to?(method.name)

        target_method = object.public_method(method.name)
        if target_method.parameters.count != method.parameters.count ||
           target_method.parameters.map {|p| p.first } != method.parameters.map {|p| p.first}
          raise Quacky::DuckTypeVerificationFailure, "definitions of method `#{method.name}` differ in parameters accepted."
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
