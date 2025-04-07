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
gem 'aruba', require: false
gem 'capybara', require: false
gem 'cucumber', require: false
gem 'rspec', require: false
gem 'timecop', require: false

# Optional dependencies, included for tests
gem 'kramdown'
gem 'rack'
gem 'activesupport', RUBY_VERSION < '3.2' ? '~> 7.0' : '~> 8.0'

# Code Quality
gem 'simplecov', require: false
