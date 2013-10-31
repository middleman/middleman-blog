source 'https://rubygems.org'

gem "middleman-core", :github => "middleman/middleman"

# Specify your gem's dependencies in middleman-blog.gemspec
gemspec

gem "rake",     "~> 10.0.3", :require => false
gem "yard",     "~> 0.8.0", :require => false

# Test tools
gem "cucumber", "~> 1.3.1"
gem "fivemat"
gem "aruba",    "~> 0.5.1"
gem "rspec",    "~> 2.12"
gem "simplecov"

gem "timecop",  "~> 0.4.0"
gem "nokogiri", "~> 1.5.0" # 1.6.0 requires Ruby 1.9+ but we still test on 1.8
gem "kramdown"

# Code Quality
gem "cane", :platforms => [:mri_19, :mri_20], :require => false

platforms :ruby do
  gem "redcarpet", /^1\.8/.match(RUBY_VERSION) ? "~> 2.0" : "~> 3.0"
end

# Cross-templating language block fix for Ruby 1.8
platforms :mri_18 do
  gem "ruby18_source_location"
end
