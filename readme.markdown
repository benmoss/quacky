# Quacky

[![Build Status](https://secure.travis-ci.org/moonmaster9000/quacky.png)](http://travis-ci.org/moonmaster9000/quacky)

Ruby doubles and expectations that conform to duck types.

## Installation

Standalone: `gem install quacky`

Or, in a Gemfile: 

```ruby
gem "quacky"
```


## The problem

Writing a test suite that tests everything, but tests each bit of functionality just once, is hard.
You can use doubles in your tests to stub out collaborators, but how do you ensure those doubles actually
conform to the duck type they represent? 

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


## Solutions

There are different ways to solve this problem. Here we'll look at two.


### Integration tests

You could write an integration test to ensure that `Teacher` integrates with its collaborators correctly. If 
object construction is cheap, and algorithms are efficient, then this can be a perfectly pragmatic solution.

But what if the construction of objects in your system are unavoidably slow? Or what if the algorithms in your system
are unavoidably slow? Then your integration tests will be slow. And if your test suite is slow, it's less
likely that you'll run it everytime you add code. Even worse, slow test suites have a tendency to get slower. You 
resign yourself to their slow execution, and pay less attention to making new tests fast.


### Duck Type Verification with Quacky

The `quacky` gem facilitates duck type verification, another approach to solving this problem that avoids
integration testing.

Start by crafting the duck type for your classroom collaborator:

```ruby
module Dismissable
  def dismiss break_time; end
end
```

Next, ensure that `Classroom` conforms to the duck type:

```ruby
describe Classroom do
  it { should quack_like Dismissable }
end
```

Next, update your `Teacher` test to use a classroom double that conforms to the duck type:

```ruby
describe Teacher do
  describe "#take_break" do
    let(:classroom) { Quacky.double Dismissable }
    let(:teacher)   { Teacher.new classroom }

    it "should send the `dismiss` message to the classroom" do
      classroom.should_receive(:dismiss)
      teacher.take_break
    end
  end
end
```

Notice that we used `Quacky.double Dismissable` instead of `double :classroom` in our test.

Now, when we run our test, we'll receive a `Quacky::MethodSignatureMismatch: wrong number of arguments (0 for 1)` exception.


## Tradeoffs / Caveats

Quacky makes it possible to construct a fast test suite that isolates the object under test from it's collaborators
while providing you with more confidance that your test suite isn't providing you with false positives.

However, although you'll likely write far fewer integration tests, you'll still have to maintain the duck types 
in your tests. Even with a library like Quacky, this can seem tedious. On the other hand, perhaps
it will make the design (or mis-design) of your system more obvious.

Lastly, Quacky can't protect you from `method_missing`, `*args`, or mismatched return types. And if you truly need
all that protection... perhaps you should simply use a statically typed language.


## The Full Quacky API

Creating a double: 

```ruby
Quacky.double SomeModule
```

You can give it multiple modules: `Quacky.double SomeModule, SomeOtherModule`

Setting up stubs on the double: 

```ruby
d = Quacky.double SomeModule
d.stub(:some_method).and_return "foo"
```

Note: you can't stub a method that doesn't exist on the double. For that reason, when you're stubbing on a 
Quacky double, a stub without an `and_return` is meaningless.

You can scope the stub to calls with specific arguments:

```ruby
d.stub(:some_method).with(some_argument).and_return "foo"
```

Replace `stub` with `should_receive` to setup an actual expectation in your test.

Lastly, if you create modules representing duck types, use the `quack_like` rspec matcher to ensure that your real collaborators also conform to that
duck type so that you can ensure that you keep your doubles in sync with their real counterparts.

```ruby
describe Classroom do
  it { should quack_like Dismissable }
end
```
