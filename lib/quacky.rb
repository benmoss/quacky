module Quacky
  class Definition
    attr_reader :duck_source

    def methods(*method_names)
      raise "You must define a source before listing methods." unless duck_source

      method_names.each do |method_name|
        all_methods << duck_source.public_method(method_name)
      end
    end

    def all_methods
      @all_methods ||= []
    end

    def source s
      @duck_source = s
    end
  end
end


