require 'bundler'
Bundler::GemHelper.install_tasks

require 'cucumber/rake/task'

require 'middleman-core'

Cucumber::Rake::Task.new(:cucumber, 'Run features that should pass') do |t|
  ENV["TEST"] = "true"

  exempt_tags = ""
  exempt_tags << "--tags ~@nojava" if RUBY_PLATFORM == "java"
  exempt_tags << "--tags ~@three_one" unless ::Middleman::VERSION.match(/^3\.1\./)

  t.cucumber_opts = "--color --tags ~@wip #{exempt_tags} --strict --format #{ENV['CUCUMBER_FORMAT'] || 'pretty'}"
end

require 'rake/clean'

task :test => ["cucumber"]

desc "Build HTML documentation"
task :doc do
  sh 'bundle exec yard'
end
