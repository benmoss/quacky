require 'spec_helper'

module Quacky
  describe Stub, "#and_return" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck!)) }

    context "static value" do
      it "should return the static value when called" do
        return_value = double :return_value
        q_expectation.and_return return_value
        q_expectation.call(double :argument).should == return_value
      end
    end

    context "block return value" do
      context "explicit" do
        it "should return the value returned by the block" do
          return_value = double :return_value
          q_expectation.and_return { return_value }
          q_expectation.call(double :argument).should == return_value
        end
      end

      context "implicit" do
        it "should return the value returned by the block" do
          return_value = double :return_value
          q_expectation = Quacky::Stub.new(object.public_method(:duck!)) { return_value }
          q_expectation.call(double :argument).should == return_value
        end
      end
    end

    it "returns self to faciliate chaining" do
      q_expectation.and_return(1).should == q_expectation
    end
  end
end
