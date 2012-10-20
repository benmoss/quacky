module MiniTest; end

require_relative '../../../lib/quacky/quacky'
require_relative '../../../lib/quacky/minitest_setup'

describe Quacky do
  describe ".mock" do
    it "should be an alias for .double" do
      Quacky.public_method(:mock).should == Quacky.public_method(:double)
    end
  end
end

Object.send(:remove_const, :MiniTest)
