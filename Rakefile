require 'cucumber/rake/task'
require 'rspec/core/rake_task'

load File.join(File.dirname(__FILE__),
               %w(vendor udaeta lib udaeta tasks udaeta.rake))

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok) do |t|
    t.profile = :default
  end

  Cucumber::Rake::Task.new(:wip) do |t|
    t.profile = :wip
  end

  desc 'Run all features'
  task :all => [:ok, :wip]

  task :all => 'udaeta:check_dependencies'
  task :ok => 'udaeta:check_dependencies'
  task :wip => 'udaeta:check_dependencies'
end

RSpec::Core::RakeTask.new
