if defined? RSpec
  RSpec.configure do |config|
    config.before(:each) do
      Quacky.clear_expectations!
    end

    config.after(:each) do
      Quacky.expectations.map &:validate_satisfaction!
    end
  end
end
