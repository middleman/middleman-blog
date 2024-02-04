# frozen_string_literal: true

source 'https://rubygems.org'

gem 'middleman-core', '~> 4.5'
gem 'middleman-cli', '~> 4.5'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

# Build and doc tools
gem 'rake', '~> 13.1', require: false
gem 'yard', '~> 0.9', require: false

# Test tools
gem 'aruba', '~> 0.14', require: false
gem 'capybara', '~> 2.5', require: false
gem 'cucumber', '~> 3.0', require: false
gem 'rspec', '~> 3.0', require: false
gem 'timecop', '~> 0.6', require: false

# Optional dependencies, included for tests
gem 'kramdown'
gem 'nokogiri', RUBY_VERSION < '2.6' ? '~> 1.12.0' : '>= 0', require: false

# Code Quality
gem 'rubocop', require: false
gem 'rubocop-performance', require: false
gem 'simplecov', require: false
