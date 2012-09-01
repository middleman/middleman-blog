# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-blog/version"

Gem::Specification.new do |s|
  s.name        = "middleman-blog"
  s.version     = Middleman::Blog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds", "Ben Hollis"]
  s.email       = ["me@tdreyno.com", "ben@benhollis.net"]
  s.homepage    = "https://github.com/middleman/middleman-blog"
  s.summary     = %q{A blog foundation using Middleman}
  s.description = %q{A blog foundation using Middleman}

  s.rubyforge_project = "middleman-blog"

  s.files         = `git ls-files -z`.split("\0")
  s.test_files    = `git ls-files -z -- {fixtures,features}/*`.split("\0")
  s.require_paths = ["lib"]
  
  s.add_dependency("middleman-core", ["~> 3.0.1"])
  s.add_dependency("maruku", ["~> 0.6.0"])
  s.add_dependency("tzinfo", ["~> 0.3.0"])
end
