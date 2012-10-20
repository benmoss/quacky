require 'rspec/core/rake_task'
require 'cucumber/rake/task'


Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "integration/features --format pretty"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color -f doc"
end

task :default => [:spec, :features]
