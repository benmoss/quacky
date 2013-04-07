require 'spec_helper'

module Quacky
  describe ClassInspect, "#inspect" do
    it "is a string representation of the class double" do
      object = double(:somethin)
      object.extend(ClassInspect)
      object.inspect.should == "Quacky::ClassDouble(:)"
    end
  end
end
