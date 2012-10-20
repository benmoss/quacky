require 'spec_helper'

module Quacky
  describe "mocks" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    describe Stub do
      let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck!)) }

      describe "#with" do
        it "should raise an exception if the original method's signature mismatches" do
          expect { q_expectation.with 1,2,3 }.to raise_exception Quacky::MethodSignatureMismatch, "#{object.inspect}#duck! was called with the wrong number of arguments (3 for 1)"
        end
      end

      describe "#and_return" do
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
      end

      describe "#call" do
        subject { q_expectation }

        context "with invalid arguments" do
          it "should raise an exception" do
            expect{ q_expectation.call(1,2,3)}.to raise_exception Quacky::MethodSignatureMismatch
          end
        end

        context "called with unexpected arguments" do
          it "should raise a Quacky::UnexpectedArguments exception" do
            q_expectation.with double(:expected_argument)
            expect { q_expectation.call double(:unexpected_arguments) }.to raise_exception Quacky::UnexpectedArguments
          end
        end

        context "called with expected arguments" do
          it "should return the configured return value" do
            q_expectation.with("foo").and_return "bar"
            q_expectation.call("foo").should == "bar"
          end
        end
      end

      describe "validate_satisfaction!" do
        subject { q_expectation.validate_satisfaction! }

        context "no with expectation" do
          before { q_expectation.call double(:argument) }
          specify { expect { subject }.not_to raise_exception }
        end

        context "not called at all" do
          specify { expect { subject }.to raise_exception Quacky::UnsatisfiedExpectation, "Expected `duck!` to be called." }
        end

        context "with expectation" do
          let(:argument) { double :argument }

          before { q_expectation.with argument }

          context "called with matching argument" do
            before { q_expectation.call argument }
            specify { expect { subject }.not_to raise_exception }
          end
        end
      end
    end
  end
end
