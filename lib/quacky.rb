module Quacky
  extend self

  def double duck_type
    Object.new.tap do |object|
      object.extend duck_type
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

    class_modules    = [class_modules] unless class_modules.kind_of? Array
    instance_modules = [instance_modules] unless instance_modules.kind_of? Array

    [class_modules, instance_modules]
  end
end
