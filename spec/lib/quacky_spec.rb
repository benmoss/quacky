require_relative '../../lib/quacky'

module Duck
  def duck arg
  end
end

describe Quacky do
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
    describe ".stub" do
      let(:q_double) { Quacky.double Duck }

      it "should raise an exception if the method does not already exist on the double" do
        expect { q_double.stub("random_method_#{rand 1000000}") }.to raise_exception Quacky::NoMethodError
      end

      it "should initialize and return a new Quacky::MessageExpectation otherwise" do
        expectation = double(:expectation)
        Quacky::MessageExpectation.should_receive(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.stub(:duck).should == expectation
      end

      it "should reroute calls to the original method to call the expectation's call method" do
        expectation = double(:expectation)
        argument = double :argument
        Quacky::MessageExpectation.stub(:new).with(q_double.public_method(:duck)).and_return expectation
        q_double.stub(:duck)
        expectation.should_receive(:call).with argument
        q_double.duck(argument)
      end
    end
  end
end

module Quacky
  describe MessageExpectation do
    let(:object) do
      Class.new do
        include Duck
      end.new
    end

    let(:q_expectation) { Quacky::MessageExpectation.new(object.public_method(:duck)) }
    
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

      context "called with invalid arguments" do
        it "should raise an exception" do
          expect{ q_expectation.call(1,2,3)}.to raise_exception Quacky::MethodSignatureMismatch
        end
      end

      context "no with expectation" do
        before { q_expectation.call double(:argument) }
        it { should be_satisfied }
      end

      context "with expectation" do
        let(:argument) { double :argument }

        before { q_expectation.with argument }

        context "called with matching argument" do
          before { q_expectation.call argument }
          it { should be_satisfied }
        end

        context "called with non-matching argument" do
          before { q_expectation.call rand }
          it { should_not be_satisfied }
        end
      end
    end
  end
end
