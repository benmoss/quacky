Feature: Stubs

  Scenario: called with a block return value
    Given the following test code:
      """
        module Announcable
          def announce; end
        end

        describe Announcable do
          let(:announcer) { Quacky.double :announcer, Announcable }

          it "should support stubbing with a block return value" do
            announcer.stub(:announce) { "hear ye hear ye!!" }
            announcer.announce.should == "hear ye hear ye!!"
          end
        end
      """

    When I run rspec

    Then I should see 1 successful example in the RSpec output
