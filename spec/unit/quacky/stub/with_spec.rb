require 'spec_helper'
module Quacky
  describe Stub, "#with" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck!)) }

    it "adds the arguments as part of the stub" do
      q_expectation.with(1)
      expect { q_expectation.call(2) }.to raise_exception(Quacky::UnexpectedArguments, "duck! was called with unexpected arguments: 2. expected: 1")
    end

    it "returns self to faciliate chaining" do
      q_expectation.with(1).should == q_expectation
    end

    it "should raise an exception if the original method's signature mismatches" do
      expect { q_expectation.with(1,2,3) }.to raise_exception Quacky::MethodSignatureMismatch, "#{object.inspect}#duck! was called with the wrong number of arguments (3 for 1)"
    end
  end
end
