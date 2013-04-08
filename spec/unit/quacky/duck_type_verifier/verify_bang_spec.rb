require 'spec_helper'

describe Quacky::DuckTypeVerifier, '#verify!' do
  let(:conforming_object) do
    Class.new do
      def quack arg1,arg2,arg3=nil; end
      def waddle; end
    end.new
  end

  let(:duck_type_module) do
    Module.new do
      def quack a,b,c=nil; end
      def waddle; end
    end
  end

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
    it "should return true" do
      expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
    end
  end

  context "given a method that accepts any number of arguments" do
    context "when the object conforms" do
      before do
        def conforming_object.quack(*args); end
      end

      it "should return true" do
        expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
      end
    end

    context "when the object does not conform" do
      let(:non_conforming_object) do
        Class.new do
          def quack(*args); end
        end.new
      end

      it "raises a Quacky::DuckTypeVerificationFailure" do
        expect { verifier.verify! non_conforming_object }.to raise_exception Quacky::DuckTypeVerificationFailure, "object does not respond to `waddle`"
      end
    end
  end

  context "given a method that accepts a named block" do
    before do
      def conforming_object.quack(arg1,arg2,arg3=nil,&block); end
    end

    it "should return true" do
      expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
    end
  end

  context "given an object that responds to but does not explicitly implement a method" do
    let(:unexplicitly_conforming_object) do
      Class.new do
        def respond_to?(method_name, include_private = false)
          method_name.to_s == 'quack' || super
        end
      end.new
    end

    it "should not raise a DuckTypeVerificationError" do
      expect { verifier.verify! conforming_object }.not_to raise_exception Quacky::DuckTypeVerificationFailure
    end

    it "should not raise a NameError" do
      expect { verifier.verify! conforming_object }.not_to raise_exception NameError
    end
  end
end
