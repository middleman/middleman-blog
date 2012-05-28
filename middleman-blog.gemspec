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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
  
  s.add_dependency("middleman-core", [">= 3.0.0.beta.3"])
  s.add_dependency("maruku", ["~> 0.6.0"])
end