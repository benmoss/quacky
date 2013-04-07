require 'spec_helper'

module Quacky
  describe Double, ".new" do
    it "extends itself with the Expectations module" do
      Double.new(:test).singleton_class.ancestors.should include(Expectations)
    end

    it "extends itself with the duck types provided" do
      Double.new(:test, Duck).singleton_class.ancestors.should include(Duck)
    end
  end
end
