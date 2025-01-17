require "./lib/middleman-blog/version"

Gem::Specification.new do | s |
  s.name          = "middleman-blog"
  s.version       = Middleman::Blog::VERSION
  s.platform      = Gem::Platform::RUBY
  s.authors       = [ "Thomas Reynolds", "Ben Hollis", "Ian Warner" ]
  s.email         = [ "me@tdreyno.com", "ben@benhollis.net", "ian.warner@drykiss.com" ]
  s.homepage      = "https://github.com/middleman/middleman-blog"
  s.summary       = %q{ Blog engine for Middleman }
  s.description   = %q{ Blog engine for Middleman }
  s.license       = "MIT"
  s.files         = `git ls-files -z`.split( "\0" )
  s.test_files    = `git ls-files -z -- {fixtures,features}/*`.split( "\0" )
  s.add_dependency("middleman-core", ">= 4.0.0")
  s.add_dependency("tzinfo", ">= 0.3.0")
  s.add_dependency("addressable", "~> 2.3")
end
