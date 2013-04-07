require 'spec_helper'

module Quacky
  describe Stub, "#validate_satisfaction!" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck!)) }

    subject { q_expectation.validate_satisfaction! }

    context "when called" do
      before { q_expectation.call double(:argument) }
      specify { expect { subject }.not_to raise_exception }
    end

    context "when not called" do
      specify { expect { subject }.to raise_exception(Quacky::UnsatisfiedExpectation, "Expected `duck!` to be called.") }
    end
  end
end
