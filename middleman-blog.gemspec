# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "middleman-blog/version"

Gem::Specification.new do |s|
  s.name        = "middleman-blog"
  s.version     = Middleman::Blog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Thomas Reynolds"]
  s.email       = ["me@tdreyno.com"]
  s.homepage    = "https://github.com/tdreyno/middleman-blog"
  s.summary     = %q{A blog foundation using Middleman}
  s.description = %q{A blog foundation using Middleman}

  s.rubyforge_project = "middleman-blog"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_runtime_dependency("middleman-core", [">= 3.0.0.beta.2"])
end
