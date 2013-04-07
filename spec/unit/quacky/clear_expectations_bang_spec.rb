require 'spec_helper'

describe Quacky, "#clear_expectations!" do
  it "should reset #expectations to an empty collection" do
    Quacky.expectations.should be_empty
    Quacky.expectations << "foo"
    Quacky.clear_expectations!
    Quacky.expectations.should be_empty
  end
end
