source 'https://rubygems.org'

gem "middleman-core", :github => "middleman/middleman", :branch => 'v3-stable'

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

gem "rake",     "~> 10.1.0", :require => false
gem "yard",     "~> 0.8.0", :require => false

# Test tools
gem "cucumber", "~> 1.3.1"
gem "fivemat"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"
gem "simplecov"

gem "timecop",  "~> 0.6.3"
gem "nokogiri"
gem "kramdown"

# Code Quality
gem "cane", :platforms => [:mri_19, :mri_20], :require => false
gem 'coveralls', :require => false

platforms :ruby do
  gem "redcarpet", "~> 3.0"
end
