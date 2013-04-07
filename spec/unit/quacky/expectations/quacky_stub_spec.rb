require 'spec_helper'

describe Quacky::Expectations, "#quacky_stub" do
  let(:q_double) { Quacky.double :duck, Duck }
  let(:expectation) { double(:expectation) }

  it "should raise an exception if the method does not already exist on the double" do
    method_name = "random_method_#{rand 1000000}"
    expect { q_double.quacky_stub(method_name) }.to raise_exception(Quacky::NoMethodError, "<Quacky::Double :duck> does not define `#{method_name}'")
  end

  it "should initialize and return a new Quacky::Stub" do
    Quacky::Stub.should_receive(:new).with(q_double.public_method(:duck!)).and_return expectation
    q_double.quacky_stub(:duck!).should == expectation
  end

  it "should reroute calls to the original method to call the expectation's call method" do
    Quacky::Stub.stub(:new).with(q_double.public_method(:duck!)).and_return expectation
    q_double.quacky_stub(:duck!)

    argument = double :argument
    expectation.should_receive(:call).with argument
    q_double.duck!(argument)
  end

  it 'supports passing a block' do
    Quacky::Stub.should_receive(:new).with(q_double.public_method(:duck!)) do |&block|
      block.call.should == "foo"
    end
    q_double.quacky_stub(:duck!) { "foo" }
  end

  it "normalizes the method name to a symbol" do
    q_double.quacky_stub("duck!")
    expect { q_double.duck!(double) }.not_to raise_exception
  end

  it "maintains ! characters in method names" do
    mallard = Module.new do
      def quack; end
      def quack!; end
    end
    q_double = Quacky.double(:enum, mallard)
    expectation = double(:expectation)
    expectation2 = double(:expectation)
    q_double.quacky_stub(:quack).and_return(expectation)
    q_double.quacky_stub(:quack!).and_return(expectation2)
    q_double.quack.should == expectation
  end
end
