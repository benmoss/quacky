require 'rspec/core/rake_task'
require 'cucumber/rake/task'
require 'mutant'
require 'devtools'

Devtools.init_rake_tasks

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "integration/features --format pretty"
end

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--color -f doc"
end

task :default => [:spec, :features]

desc 'Run mutant'
task :mutant do
  status = Mutant::CLI.run(%W(-r ./spec/spec_helper.rb ::Quacky --rspec-dm2))
  if status.nonzero?
    raise 'Mutant task is not successful'
  end
end
