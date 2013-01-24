# CHANGELOG

## 0.2.8

Support methods that "respond_to" a method but implement the method via method_missing. (The Kimmel - https://github.com/moonmaster9000/quacky/pull/13) 

## 0.2.7

Bug fix for accidental minitest syntax injection in rspec controller tests. (Ben Moss - https://github.com/moonmaster9000/quacky/pull/11/files)

## 0.2.6

New features courtesy of Sir Ben Moss:

* stubbed return values with blocks (`double.stub(:value) { "return value" }`)
* better error messages for calling non-existant messages on quacky doubles

## 0.2.5

More sporting method argument matching.

For example, you could now use "delegate" in your production code, and it will match the duck type without fail.

## 0.2.4

MIT License

## 0.2.3

MiniTest::Unit support

## 0.2.2

Better exception messages for UnsatisfiedExpectation and UnexpectedArguments.

## 0.2.1

Better exception messages for DuckTypeVerificationFailure and MethodSignatureMismatch exceptions.
