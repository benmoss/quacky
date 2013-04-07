require 'spec_helper'

describe Quacky, "#expectations" do
  it "stores expectations" do
    expectation = double(:expectation)
    Quacky.expectations << expectation
    Quacky.expectations.should == [expectation]
  end
end
