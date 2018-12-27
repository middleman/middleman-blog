
source 'https://rubygems.org'

# Middleman Gems
gem 'middleman-cli', '~> 4.2'
gem 'middleman-core', '~> 4.2'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

# Build and doc tools
gem 'rake', '~> 12.3', require: false
gem 'yard', '~> 0.9.11', require: false

# Test tools
gem 'aruba', '~> 0.14.0', require: false
gem 'byebug'
gem 'capybara', '~> 2.5.0', require: false
gem 'cucumber', '~> 3.0', require: false
gem 'rspec', '~> 3.0', require: false

# Pry tools
gem 'pry'
gem 'pry-rescue'
gem 'pry-stack_explorer'

gem 'kramdown'
gem 'nokogiri', '~> 1.9.1'
gem 'timecop', '~> 0.6.3'

# Code Quality
gem 'rubocop', '~> 0.61.1', require: false
gem 'simplecov', '~> 0.10', require: false

# Set the ruby platform - not windows
platforms :ruby do
  gem 'redcarpet', '~> 3.1' # Latest 3.4.0
end
