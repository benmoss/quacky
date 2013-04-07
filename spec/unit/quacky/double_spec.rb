require 'spec_helper'

describe Quacky, "#double" do
  it "returns a new Double" do
    name = double(:name)
    duck_types = [double(:duck_type), double(:duck_type)]
    double = double(:double)
    Quacky::Double.stub(:new).with(name, duck_types).and_return(double)

    Quacky.double(name, duck_types).should == double
  end
end
