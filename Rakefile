# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/gem/maintenance/install_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ["--autocorrect"]
end

Cucumber::Rake::Task.new do |t|
  t.profile = "rake"
end

namespace :publish do
  desc "Push the built .gem file to rubygems.org"
  task :rubygems do
    require_relative "rakelib/rubygems_publisher"
    RubygemsPublisher.publish
  end
end

task default: :verify

desc "Run all checks"
task verify: %i[rubocop spec cucumber]
