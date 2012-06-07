SPEC_FILE   = File.expand_path(File.dirname(__FILE__)) + "/../fixtures/feature_spec.rb"
SETUP_CODE  = <<-CODE
require_relative '../../lib/quacky/quacky'
require_relative '../../lib/quacky/rspec_setup'
CODE

Given /^the following production code:$/ do |production_code|
  @production_code = production_code
end

Given /^the following test code:$/ do |test_code|
  @test_code = test_code
end

When /^I run rspec$/ do
  File.open(SPEC_FILE, "w") do |f|
    f.write [SETUP_CODE, @production_code, @test_code].join("\n")
  end

  @output = `rspec #{SPEC_FILE}`
end

Then /^I should get a "(.*?)" error in the RSpec output$/ do |snippet|
  @output.should include snippet
end

Then /^I should not get a "(.*?)" error in the RSpec output$/ do |snippet|
  @output.should_not include snippet
end
