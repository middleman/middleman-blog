# frozen_string_literal: true

source 'https://rubygems.org'

gem 'middleman-core', git: 'https://github.com/middleman/middleman.git'
gem 'middleman-cli', git: 'https://github.com/middleman/middleman.git'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

# Build and doc tools
gem 'rake', '~> 13.1', require: false
gem 'yard', '~> 0.9', require: false

# Test tools
gem 'aruba', '~> 1.0', require: false
gem 'capybara', '~> 3', require: false
gem 'cucumber', require: false
gem 'rspec', '~> 3.0', require: false
gem 'timecop', '~> 0.6', require: false

# Optional dependencies, included for tests
gem 'kramdown'
gem 'rack', '< 3'
gem 'activesupport', RUBY_VERSION < '3.1' ? '< 7.1' : '>= 0'

# Code Quality
gem 'rubocop', require: false
gem 'rubocop-performance', require: false
gem 'simplecov', require: false
