module Quacky
  extend self

  def expectations
    @expectations ||= []
  end

  def clear_expectations!
    @expectations = nil
  end

  def double(name, *duck_types)
    Double.new(name, *duck_types)
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
      extend Expectations
      include Expectations
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
