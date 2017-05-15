##
# If you do not have OpenSSL installed, change
# the following line to use 'http://'
##
source 'https://rubygems.org'

# Middleman Gems
gem "middleman-cli",  git: "https://github.com/middleman/middleman.git", branch: 'master'
gem "middleman-core", git: "https://github.com/middleman/middleman.git", branch: 'master'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

# Build and doc tools
gem 'rake', '~> 10.3', require: false # Latest 12.0.0
gem 'yard', '~> 0.8',  require: false # Latest 0.9.8

# Test tools
gem 'pry',      '~> 0.10',  require: false, group: :development # Latest 1.0.0.pre1
gem 'aruba',    '~> 0.7.4', require: false # Latest 0.14.2
gem 'capybara', '~> 2.5.0', require: false # Latest 2.13.0 middleman-core forces all plugins to declare this
gem 'rspec',    '~> 3.0',   require: false # Latest 3.6.0.beta2
gem 'cucumber', '~> 2.4',   require: false # Latest 3.0.0.pre.1

gem "timecop", "~> 0.6.3" # Latest 0.8.1
gem "nokogiri"            # Latest 1.7.1
gem "kramdown"            # Latest 1.13.2

# Code Quality
gem 'rubocop',                   '~> 0.24', require: false # Latest 0.47.1
gem 'simplecov',                 '~> 0.10', require: false # Latest 0.14.1
gem 'coveralls',                 '~> 0.8',  require: false # Latest 0.8.19
gem 'codeclimate-test-reporter', '~> 0.3',  require: false, group: :test # Latest 1.0.8

# Set the ruby platform - not windows
platforms :ruby do
  gem "redcarpet", "~> 3.1" # Latest 3.4.0
end
