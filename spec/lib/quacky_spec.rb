require_relative '../../lib/quacky/quacky'

module Duck
  def duck arg; end
end

describe Quacky::DuckTypeVerifier do
  let(:conforming_object) do
    Class.new do
      def quack arg1,arg2,arg3=nil; end
    end.new
  end

  let(:duck_type_module) do
    Module.new do
      def quack a,b,c=nil; end
    end
  end

  describe "#verify!" do
    let(:verifier) { Quacky::DuckTypeVerifier.new(duck_type_module) }

    context "non-conforming objects" do
      context "an object that doesn't even respond to the same methods" do
        let(:non_conforming_object) do
          Class.new.new
        end

        it "should raise a Quacky::DuckTypeVerificationFailure" do
          expect { verifier.verify! non_conforming_object }.to raise_exception Quacky::DuckTypeVerificationFailure
        end
      end

      context "an object that has the methods but with different parameters" do
        let(:non_conforming_object) do
          Class.new do
            def quack; end
          end.new
        end

        it "should raise a Quacky::DuckTypeVerificationFailure" do
          expect { verifier.verify! non_conforming_object }.to raise_exception Quacky::DuckTypeVerificationFailure
        end
      end
    end

    context "given a conforming object" do
      let(:conforming_object) do
        Class.new do
          def quack arg1,arg2,arg3=nil; end
        end.new
      end

      it "should return true" do
        expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
      end
    end
  end
end

describe Quacky do

  describe ".clear_expectations!" do
    it "should reset .expecatations to an empty collection" do
      Quacky.expectations.should be_empty
      Quacky.expectations << "foo"
      Quacky.clear_expectations!
      Quacky.expectations.should be_empty
    end
  end

  describe "#double" do
    let(:eigenclass) { class << Quacky.double(Duck); self; end }

    subject { eigenclass }

    its(:included_modules) { should include Duck }
  end

  describe "#class_double" do
    let(:class_double)  { Quacky.class_double class: class_ducks, instance: instance_ducks }
    let(:class_eigenclass) { class << class_double; self; end }

    shared_examples_for "quacky class double" do
      context "instance methods" do
        subject { class_double }
        its(:ancestors) { should include *instance_ducks }
      end

      context "class methods" do
        subject { class_eigenclass }
        its(:included_modules) { should include *class_ducks }
      end
    end

    context "single class and instance module" do
      let(:class_ducks)    { Module.new }
      let(:instance_ducks) { Module.new }

      it_behaves_like "quacky class double"
    end

    context "multiple class and instance modules" do
      let(:class_ducks)      { [ Module.new, Module.new ] }
      let(:instance_ducks)   { [ Module.new, Module.new ] }

      it_behaves_like "quacky class double"
    end
  end

  describe Quacky::Double do
    let(:q_double) { Quacky.double Duck }
    let(:expectation) { double(:expectation) }

    describe ".stub" do
      it "should raise an exception if the method does not already exist on the double" do
        expect { q_double.stub("random_method_#{rand 1000000}") }.to raise_exception Quacky::NoMethodError
      end

      it "should initialize and return a new Quacky::Stub otherwise" do
        Quacky::Stub.should_receive(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.stub(:duck).should == expectation
      end

      it "should reroute calls to the original method to call the expectation's call method" do
        Quacky::Stub.stub(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.stub(:duck)

        argument = double :argument
        expectation.should_receive(:call).with argument
        q_double.duck(argument)
      end
    end

    describe "should_receive" do
      it "should raise an exception if the method does not already exist on the quacky double" do
        expect { q_double.should_receive("random_method_#{rand 1000000}") }.to raise_exception Quacky::NoMethodError
      end

      it "should initialize and return a new QuackyStub otherwise" do
        Quacky::Stub.should_receive(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.should_receive(:duck).should == expectation
      end

      it "should add the generated expectation to the list of required expectations" do
        Quacky::Stub.stub(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.should_receive(:duck)    
        Quacky.expectations.should include expectation
      end
    end
  end
end

module Quacky
  describe "mocks" do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    describe Stub do
      let(:q_expectation) { Quacky::Stub.new(object.public_method(:duck)) }

      describe "#with" do
        it "should raise an exception if the original method's signature mismatches" do
          expect { q_expectation.with 1,2,3 }.to raise_exception Quacky::MethodSignatureMismatch
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
          it "should return the value returned by the block" do
            return_value = double :return_value
            q_expectation.and_return { return_value }
            q_expectation.call(double :argument).should == return_value
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
          specify { expect { subject }.to raise_exception Quacky::UnsatisfiedExpectation }
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
