TEST_FILE   = File.expand_path(File.dirname(__FILE__)) + "/../fixtures/feature_spec.rb"
SETUP_CODE  = <<-CODE
$LOAD_PATH.unshift '../../lib'
require 'minitest/autorun'
require 'quacky'
CODE

MINITEST_SETUP_CODE = (
<<-CODE
require 'minitest/autorun'
CODE
) + SETUP_CODE

Given /^the following production code:$/ do |production_code|
  @production_code = production_code
end

Given /^the following test code:$/ do |test_code|
  @test_code = test_code
end

When /^I run rspec$/ do
  File.open(TEST_FILE, "w") do |f|
    f.write [SETUP_CODE, @production_code, @test_code].join("\n")
  end

  @output = `rspec #{TEST_FILE}`
end

When /^I run minitest$/ do
  File.open(TEST_FILE, "w") do |f|
    f.write [MINITEST_SETUP_CODE, @production_code, @test_code].join("\n")
  end

  @output = `ruby #{TEST_FILE}`
end

Then /^I should see "(.*?)"$/ do |output|
  @output.should include output
end

Then /^I should get a "(.*?)" error in the RSpec output$/ do |snippet|
  @output.should include snippet
end

Then /^I should not get a "(.*?)" error in the RSpec output$/ do |snippet|
  @output.should_not include snippet
end

Then /^I should see 1 successful example in the RSpec output$/ do
  @output.should include("1 example, 0 failures")
end
