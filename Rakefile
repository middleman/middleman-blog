# frozen_string_literal: true

require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'
require 'middleman-core'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  exempt_tags = ''
  exempt_tags << "--tags 'not @nojava'" if RUBY_PLATFORM == 'java'
  t.cucumber_opts = "--color --tags 'not @wip' #{exempt_tags} --strict --format pretty"
end

desc 'Run tests, both RSpec and Cucumber'
task test: %i[spec cucumber]

require 'rspec/core/rake_task'
desc 'Run RSpec'
RSpec::Core::RakeTask.new do |spec|
  spec.pattern    = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--color', '--format documentation']
end

desc 'Build HTML documentation'
task :doc do
  sh 'bundle exec yard'
end

desc 'Run all tests'
task default: :test
