Feature: Doubles

  Scenario: called with unexpected arguments
    Given the following production code:
      """
        class Teacher
          def initialize(classroom)
            @classroom = classroom
          end

          def take_break
            @classroom.dismiss
            puts "reclaiming sanity"
          end
        end

        class Classroom
          def dismiss break_time
            #... send the kids out of the classroom
          end
        end
      """

    And the following test code:
      """
        module Dismissable
          def dismiss break_time; end
        end

        describe Teacher do
          describe "#take_break" do
            let(:classroom) { Quacky.double :classroom, Dismissable }
            let(:teacher)   { Teacher.new classroom }

            it "should send the `dismiss` message to the classroom" do
              classroom.should_receive :dismiss
              teacher.take_break
            end
          end
        end
      """

    When I run rspec

    Then I should get a "Quacky::MethodSignatureMismatch" error in the RSpec output
