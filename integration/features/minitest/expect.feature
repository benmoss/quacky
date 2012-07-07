Feature: Minitest `expect` mocks

  Scenario: Mapping minitest's `expect` to quacky's `should_receive`
    Given the following production code:
      """
        class Teacher
          def initialize(classroom)
            @classroom = classroom
          end

          def take_break
            puts "reclaiming sanity"
            @classroom.dismiss "5 minutes"
          end
        end

        class Classroom
          def dismiss break_time; end
        end
      """

    And the following test code:
      """
        require 'minitest/autorun'

        module Dismissable
          def dismiss break_time; end
        end

        class TestQuackyExpect < MiniTest::Unit::TestCase
          def setup
            @classroom = Quacky.mock :classroom, Dismissable
            @teacher = Teacher.new @classroom
          end

          def test_take_break
            @classroom.expect :dismiss, true, ["10 minutes"]
            assert_equal true, @teacher.take_break
          end
        end
      """

    When I run minitest

    Then I should see "Quacky::UnexpectedArguments"


  Scenario: Stub on quacky mock verifies method existance
    Given the following production code:
      """
        class Teacher
          def initialize(classroom)
            @classroom = classroom
          end

          def take_break
            puts "reclaiming sanity"
            @classroom.dismiss "5 minutes", "superfluous argument"
          end
        end

        class Classroom
          def dismiss break_time; end
        end
      """

    And the following test code:
      """
        require 'minitest/autorun'

        module Dismissable
          def dismiss break_time; end
        end

        class TestQuackyExpect < MiniTest::Unit::TestCase
          def setup
            @classroom = Quacky.mock :classroom, Dismissable
            @teacher = Teacher.new @classroom
          end

          def test_take_break
            @classroom.stub :dismiss, true
            assert_equal true, @teacher.take_break
          end
        end
      """

    When I run minitest

    Then I should see "Quacky::MethodSignatureMismatch"


  Scenario: class mocks work
    Given the following production code:
      """
        class Teacher
          def initialize(classroom_factory)
            @classroom = classroom_factory.for_teacher(self)
          end

          def take_break
            puts "reclaiming sanity"
            @classroom.dismiss "5 minutes", "superfluous argument"
          end
        end

        class Classroom
          def dismiss break_time; end
        end
      """

    And the following test code:
      """
        require 'minitest/autorun'

        module Dismissable
          def dismiss break_time; end
        end

        module ClassroomFactory
          def for_teacher teacher; end
        end

        class TestQuackyExpect < MiniTest::Unit::TestCase
          def setup
            @classroom_factory = Quacky.class_mock :classroom_factory, class: ClassroomFactory, instance: Dismissable
          end

          def test_take_break
            classroom = @classroom_factory.new
            @classroom_factory.expect(:for_teacher, classroom)
            @teacher = Teacher.new @classroom_factory
          end
        end
      """

    When I run minitest

    Then I should see "0 errors"
