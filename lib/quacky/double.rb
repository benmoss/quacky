module Quacky
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
end
