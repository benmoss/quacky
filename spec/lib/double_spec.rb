require 'spec_helper'

describe Quacky::Double do
  describe ".inspect" do
    it "should be formatted like `<Quacky::Double :<double_name>>`" do
      Quacky::Double.new(:test).inspect.should == "<Quacky::Double :test>"
    end
  end
end
