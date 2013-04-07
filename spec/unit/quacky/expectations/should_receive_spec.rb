require 'spec_helper'

describe Quacky::Double, "#should_receive" do
  let(:q_double) { Quacky.double :duck, Duck }
  let(:expectation) { double(:expectation) }

  it "should raise an exception if the method does not already exist on the quacky double" do
    expect { q_double.should_receive("random_method_#{rand 1000000}") }.to raise_exception Quacky::NoMethodError
  end

  it "should initialize and return a new QuackyStub otherwise" do
    Quacky::Stub.should_receive(:new).with(q_double.public_method(:duck!)).and_return expectation
    q_double.should_receive(:duck!).should == expectation
  end

  it "should add the generated expectation to the list of required expectations" do
    Quacky::Stub.stub(:new).with(q_double.public_method(:duck!)).and_return expectation
    q_double.should_receive(:duck!)
    Quacky.expectations.should include expectation
  end

  it "should support methods ending in !, ?, and regular letters" do
    q_double = Quacky.double(:quacky_double, Module.new do
      def bang!; end
      def question?; end
      def regular; end
    end)

    q_double.should_receive(:bang!).and_return "bang"
    q_double.should_receive(:question?).and_return "question"
    q_double.should_receive(:regular).and_return "regular"

    q_double.bang!.should == "bang"
    q_double.question?.should == "question"
    q_double.regular.should == "regular"
  end

end
