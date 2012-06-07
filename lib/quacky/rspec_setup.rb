if defined? RSpec
  RSpec::Matchers.define :quack_like do |expected|
    match do |actual|
      Quacky::DuckTypeVerifier.new(expected).verify! actual
    end
  end

  RSpec.configure do |config|
    config.before(:each) do
      Quacky.clear_expectations!
    end

    config.after(:each) do
      Quacky.expectations.map &:validate_satisfaction!
    end
  end
end
