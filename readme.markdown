# Quacky

[![Build Status](https://secure.travis-ci.org/moonmaster9000/quacky.png)](http://travis-ci.org/moonmaster9000/quacky)
[![Build Dependency Status](https://gemnasium.com/moonmaster9000/quacky.png)](https://gemnasium.com/moonmaster9000/quacky.png)

Ruby doubles and expectations that conform to duck types.

## Installation

Standalone: `gem install quacky`

Or, in a Gemfile:

```ruby
gem "quacky"
```

Quacky currently supports only two test frameworks: `rspec` and `minitest`.

Checkout the `MiniTest` section at the end of this README if you'd like to learn how to use it with that framework.

## The Goal

Write a test suite that tests everything, but only tests each bit of functionality once.

## The problem

Acheiving that goal requires us to use mocks and stubs, and in a dynamic language like Ruby, it's quite
easy to end up with false positive tests.

Consider the following code:

```ruby
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
  def dismiss
    #... send the kids out of the classroom
  end
end
```

A teacher has a classroom, and the teacher dismisses the class by calling the `dismiss` method on the classroom.

A test for the `Teacher` class might look like this:

```ruby
describe Teacher do
  describe "#take_break" do
    let(:classroom) { double :classroom }
    let(:teacher)   { Teacher.new classroom }

    it "should send the `dismiss` message to the classroom" do
      classroom.should_receive(:dismiss)
      teacher.take_break
    end
  end
end
```

Now imagine that the `Classroom#dismiss` method changes to require an argument:

```ruby
class Classroom
  def dismiss break_time
    # send kids out of class
    # tell them to return after break_time has passed
  end
end
```

So what's the problem? The `Teacher` tests still pass, though they shouldn't. In production, this code will explode
with an `Argument Error: wrong number of arguments (0 for 1)`. Nothing about these expectations force us to keep
the `should_receive(:dismiss)` expectation in sync with the real collaborator's method signature.


## Duck Type Verification with Quacky

The `quacky` gem facilitates duck type verification. Start by adding a module to your test suite that represents
the particular duck type of Classroom that we're relying on in the `Teacher` class:

```ruby
module Dismissable
  def dismiss break_time; end
end

describe Classroom do
  it { should quack_like Dismissable }
end
```

We used the `quack_like` matcher in our `Classroom` spec to ensure that instances of `Classroom` conform to the
`Dismissable` duck type. If we had other objects in our production code that need to conform to the same duck type,
we'd write the same test for those objects as well.

Note: the `Dismissable` module should only exist in your test suite, and should never be included in your production
code, or mixed into anything. It simply exists to represent a duck type.

Next, change the `double :classroom` in your spec to `Quacky.double :classroom, Dismissable`:

```ruby
module Dismissable
  def dismiss break_time; end
end

describe Teacher do
  describe "#take_break" do
    let(:classroom) { Quacky.double :classroom, Dismissable }
    let(:teacher)   { Teacher.new classroom }

    it "should send the `dismiss` message to the classroom" do
      classroom.should_receive(:dismiss)
      teacher.take_break
    end
  end
end
```

Now, when we run our test, we'll receive a `Quacky::MethodSignatureMismatch: wrong number of arguments (0 for 1)` exception.

If we fix our `Teacher#take_break` production code to use the `dismiss` method correctly, then the test will pass:

```ruby
class Teacher
  def take_break
    @classroom.dismiss 5.minutes
    puts "reclaiming sanity"
  end
end
```

## Tradeoffs / Caveats

Quacky makes it possible to construct a fast test suite that isolates the object under test from it's collaborators
while reducing the number of false positives.

However, although you'll likely write far fewer integration tests, you'll still have to maintain the duck types
in your tests. Even with a library like Quacky, this can seem tedious. On the other hand, perhaps
it will make the design (or mis-design) of your system more obvious.

Lastly, Quacky can't protect you from `method_missing`, `*args`, or mismatched return types. And if you truly need
all that protection... perhaps you should simply use a statically typed language.


## The Full Quacky API

### RSpec

Creating a double:

```ruby
Quacky.double :double_name, SomeModule
```

You can give it multiple modules: `Quacky.double :double_name, SomeModule, SomeOtherModule`

You can also create a class double:

```ruby
Quacky.class_double :class_double_name, class: ClassDuckType, instance: InstanceDuckType
```

The double will represent a class that conforms to the `ClassDuckType`. Instances of the double will conform to
the `InstanceDuckType`.

Once again, you can give multiple modules for either the `class` or `instance` interface (or both):

```ruby
Quacky.class_double :class_double_name, class: [ClassDuckType, AnotherClassDuckType], instance: [InstanceDuckType, AnotherInstanceDuckType]
```

Setting up stubs on the double:

```ruby
d = Quacky.double :double_name, SomeModule
d.stub(:some_method).and_return "foo"
```

Note: you can't stub a method that doesn't exist on the double (that would defeat the purpose of `Quacky`).
For that reason, when you're stubbing on a Quacky double, a stub without an `and_return` is meaningless. However,
I've preserved the basic rspec expectation syntax.

You can scope the stub to calls with specific arguments:

```
d.stub(:some_method).with("some_argument").and_return "foo"
```

Replace `stub` with `should_receive` to setup an actual expectation in your test.

Lastly, if you add modules to your test suite representing duck types, use the `quack_like` rspec matcher to ensure
that your real collaborators also conform to that duck type so that you can ensure that you keep your doubles
in sync with their real counterparts.

```ruby
describe SomeObject do
  it { should quack_like SomeDuckType }
  its(:class) { should quack_like SomeOtherDuckType }
end
```


### MiniTest/Unit

Quacky automatically extends itself with MiniTest-style syntax and matchers if it detects the `MiniTest` constant exists.

Creating a mock object:

```ruby
Quacky.mock :double_name, SomeModule
```

You can give it multiple modules: `Quacky.mock :double_name, SomeModule, SomeOtherModule`

You can also create a class mock:

```ruby
Quacky.class_mock :class_double_name, class: ClassDuckType, instance: InstanceDuckType
```

The double will represent a class that conforms to the `ClassDuckType`. Instances of the double will conform to
the `InstanceDuckType`.

Once again, you can give multiple modules for either the `class` or `instance` interface (or both):

```ruby
Quacky.class_mock :class_double_name, class: [ClassDuckType, AnotherClassDuckType], instance: [InstanceDuckType, AnotherInstanceDuckType]
```

Setting up stubs on the double:

```ruby
d = Quacky.mock :double_name, SomeModule
d.stub :some_method, "foo"
```

Note: you can't stub a method that doesn't exist on the double (that would defeat the purpose of `Quacky`).
For that reason, when you're stubbing on a Quacky double, a stub without a second argument (the return value) is meaningless. However,

You can scope the stub to calls with specific arguments:

```
d.stub :some_method, "foo", ["some_argument"]
```

Replace `stub` with `expect` to setup an actual expectation in your test.

Lastly, if you add modules to your test suite representing duck types, include `Quacky::MiniTest::Matchers` in your test and use the `assert_quack_like` method to ensure
that your real collaborators also conform to that duck type so that you can ensure that you keep your doubles
in sync with their real counterparts.

```ruby
class SomeObjectTest < MiniTest::Unit::TestCase
  include Quacky::MiniTest::Matchers

  def test_duck_type_conformity
    assert_quacks_like SomeObject.new, SomeInstanceDuckType
    assert_quacks_like SomeClass, SomeClassDuckType
  end
end
```
