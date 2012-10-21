require 'spec_helper'

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
          expect { verifier.verify! non_conforming_object }.to raise_exception Quacky::DuckTypeVerificationFailure, "definitions of method `quack` differ in parameters accepted."
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

    context "given a method that accepts any number of arguments" do
      let(:conforming_object) do
        Class.new do
          def quack *args; end
        end.new
      end

      it "should return true" do
        expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
      end
    end

    context "given a method that accepts a named block" do
      let(:conforming_object) do
        Class.new do
          def quack arg1,arg2,arg3=nil,&block; end
        end.new
      end

      it "should return true" do
        expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
      end
    end
  end
end
