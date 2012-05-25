require_relative '../lib/quacky'

describe Quacky do
  describe Quacky::Definition do
    let(:definition) { Quacky::Definition.new }

    describe "#class_methods" do
    end

    describe "#methods" do
      let(:source) { Class.new }

      context "no source set" do
        subject { -> { definition.methods :a } }

        it { should raise_exception "You must define a source before listing methods." }
      end

      context "source set" do
        before do
          definition.source source
        end

        context "unknown method on source" do
          subject { -> { definition.methods :a } }

          it { should raise_exception NameError }
        end

        context "known method on source" do
          let(:method_name) { :some_method }

          before do
            source.instance_eval <<-EVAL
              def #{method_name} a
              end
            EVAL

            source.respond_to?(method_name).should be_true

            definition.methods method_name
          end

          subject { definition.all_methods }

          it { should include source.public_method(method_name) }
        end
      end
    end
  end
end
