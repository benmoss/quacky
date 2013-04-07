require 'spec_helper'

module Quacky
  describe InstanceInspect, "#inspect" do
    it "is a string representation of the instance double" do
      klass = double(:klass, class_double_name: "wierd")
      object = double(:somethin, class: klass)
      object.extend(InstanceInspect)
      object.inspect.should == "<Quacky::ClassDouble :wierd>"
    end
  end
end
