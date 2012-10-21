Feature: assert_quacks_like

  Scenario: Successful Duck Type Verification
    Given the following production code:
      """
        class Classroom
          def dismiss break_time
          end
        end
      """

    And the following test code:
      """
        require 'minitest/autorun'

        module Dismissable
          def dismiss break_time; end
        end

        class ClassroomTest < MiniTest::Unit::TestCase
          include Quacky::MiniTest::Matchers

          def test_duck_type_conformity
            assert_quacks_like Classroom.new, Dismissable
          end
        end
      """

    When I run minitest

    Then I should see "0 errors"
