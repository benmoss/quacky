module Quacky
  class Double
    def initialize(name, *duck_types)
      self.name = name
      duck_types.each do |duck_type|
        extend(duck_type)
      end
      extend Expectations
    end

    def inspect
      "<Quacky::Double :#{name}>"
    end

    private
    attr_accessor :name
  end
end
