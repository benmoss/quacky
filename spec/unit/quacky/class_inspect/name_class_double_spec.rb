require 'spec_helper'

module Quacky
  describe ClassInspect, "#name_class_double" do
    it "assigns a name to the double" do
      object = double(:somethin)
      object.extend(ClassInspect)
      name = double(:name)
      object.name_class_double(name)
      object.class_double_name.should == name
    end
  end
end

