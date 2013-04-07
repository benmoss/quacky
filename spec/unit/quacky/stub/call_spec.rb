require 'spec_helper'

module Quacky
  describe Stub, "#call" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck!)) }

    subject { q_expectation }

    context "with invalid arguments" do
      it "should raise an exception" do
        expect{ q_expectation.call(1,2,3)}.to raise_exception Quacky::MethodSignatureMismatch
      end
    end

    context "when a return value is specified" do
      it "returns it" do
        q_expectation.and_return "bar"
        q_expectation.call(double).should == "bar"
      end
    end

    context "when an expectation was set on the arguments" do
      it "should return the configured return value when called with correct arguments" do
        q_expectation.with("foo").and_return "bar"
        q_expectation.call("foo").should == "bar"
      end

      it "should raise a Quacky::UnexpectedArguments exception when called with unexpected arguments" do
        q_expectation.with double(:expected_argument)
        expect { q_expectation.call double(:unexpected_arguments) }.to raise_exception Quacky::UnexpectedArguments
      end
    end
  end
end
