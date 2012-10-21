Feature: quack_like

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
        module Dismissable
          def dismiss break_time; end
        end

        describe Classroom do
          it { should quack_like Dismissable }
        end
      """

    When I run rspec

    Then I should not get a "Quacky::DuckTypeVerificationFailure" error in the RSpec output


  Scenario: Unsuccessful Duck Type Verification
    Given the following production code:
      """
        class Classroom
          def dismiss
          end
        end
      """

    And the following test code:
      """
        module Dismissable
          def dismiss break_time; end
        end

        describe Classroom do
          it { should quack_like Dismissable }
        end
      """

    When I run rspec

    Then I should get a "Quacky::DuckTypeVerificationFailure" error in the RSpec output


  Scenario: Unsuccessful Multiple Duck Type Verification
    Given the following production code:
      """
        class Classroom
          def dismiss break_time; end
        end
      """

    And the following test code:
      """
        module Dismissable
          def dismiss break_time; end
        end

        module Cleanable
          def clean! time; end
        end

        describe Classroom do
          it { should quack_like Dismissable, Cleanable }
        end
      """

    When I run rspec

    Then I should get a "Quacky::DuckTypeVerificationFailure" error in the RSpec output


  Scenario: Unsuccessful Duck Type Verification
    Given the following production code:
    """
        class Classroom
          def dismiss(*args, &block)
          end
        end
      """

    And the following test code:
    """
        module Dismissable
          def dismiss break_time; end
        end

        describe Classroom do
          it { should quack_like Dismissable }
        end
      """

    When I run rspec

    Then I should not get a "Quacky::DuckTypeVerificationFailure" error in the RSpec output
