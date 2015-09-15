source 'https://rubygems.org'

gem "middleman-cli", github: "middleman/middleman", branch: 'master'
gem "middleman-core", github: "middleman/middleman", branch: 'master'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

# Build and doc tools
gem 'rake', '~> 10.3', require: false
gem 'yard', '~> 0.8', require: false

# Test tools
gem 'pry', '~> 0.10', group: :development, require: false
gem 'aruba', '~> 0.7.4', require: false
gem 'rspec', '~> 3.0', require: false
gem 'cucumber', '~> 2.0', require: false

gem "timecop",  "~> 0.6.3"
gem "nokogiri"
gem "kramdown"

# Code Quality
gem 'rubocop', '~> 0.24', require: false
gem 'simplecov', '~> 0.9', require: false
gem 'coveralls', '~> 0.8', require: false
gem 'codeclimate-test-reporter', '~> 0.3', require: false, group: :test

platforms :ruby do
  gem "redcarpet", "~> 3.0"
end
