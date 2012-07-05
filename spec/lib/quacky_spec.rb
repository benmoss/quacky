require 'spec_helper'

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
    context "with a single included module" do
      let(:eigenclass) { class << Quacky.double(:duck, Duck); self; end }

      subject { eigenclass }

      its(:included_modules) { should include Duck }
    end

    context "with multiple included modules" do
      let(:another_mod) { Module.new }
      let(:eigenclass) { class << Quacky.double(:duck, Duck, another_mod); self; end }
      subject { eigenclass }
      its(:included_modules) { should include Duck, another_mod }
    end
  end

  describe "#class_double" do
    let(:class_double)  { Quacky.class_double :class_double_duck, class: class_ducks, instance: instance_ducks }
    let(:class_eigenclass) { class << class_double; self; end }
    let(:class_ducks) { [] }
    let(:instance_ducks) { [] }

    describe ".inspect" do
      context "class" do
        it "should return `Quacky::ClassDouble(:<double_name>)`" do
          class_double.inspect.should == "Quacky::ClassDouble(:class_double_duck)"
        end
      end

      context "instance" do
        it "should return `<Quacky::ClassDouble :<double_name>>`" do
          class_double.new.inspect.should == "<Quacky::ClassDouble :class_double_duck>"
        end
      end
    end

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
end
