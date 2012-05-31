require_relative '../../lib/quacky'

describe Quacky do
  describe "#double" do
    let(:duck) do Mod = Module.new end
    let(:eigenclass) { class << Quacky.double(duck); self; end }

    subject { eigenclass }

    its(:included_modules) { should include duck }
  end

  describe "#class_double" do
    context "single class and instance module" do
      let(:class_duck)    { Module.new }
      let(:instance_duck) { Module.new }
      let(:class_double)  { Quacky.class_double class: class_duck, instance: instance_duck }
      let(:class_eigenclass) { class << class_double; self; end }

      context "instance methods" do
        subject { class_double }
        its(:ancestors) { should include *instance_duck }
      end

      context "class methods" do
        subject { class_eigenclass }
        its(:included_modules) { should include *class_duck }
      end
    end

    context "multiple class and instance modules" do
      let(:class_ducks)      { [ Module.new, Module.new ] }
      let(:instance_ducks)   { [ Module.new, Module.new ] }
      let(:class_double)     { Quacky.class_double class: class_ducks, instance: instance_ducks }
      let(:class_eigenclass) { class << class_double; self; end }

      context "instance methods" do
        subject { class_double }
        its(:ancestors) { should include *instance_ducks }
      end

      context "class methods" do
        subject { class_eigenclass }
        its(:included_modules) { should include *class_ducks }
      end
    end
  end
end
