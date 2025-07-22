# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = 'multi_test'
  s.version     = File.read(File.join(File.expand_path(__dir__),'VERSION'))
  s.authors     = ["Matt Wynne", "Steve Tooke"]
  s.description = 'Wafter-thin gem to help control rogue test/unit/autorun requires'
  s.summary     = "multi-test-#{s.version}"
  s.email       = 'cukes@googlegroups.com'
  s.license     = 'MIT'
  s.homepage    = "http://cukes.info"

  s.platform    = Gem::Platform::RUBY

  s.required_ruby_version = ">= 2.0"
  s.required_rubygems_version = ">= 1.6.1"
  s.files            = `git ls-files`.split("\n").
    reject { |path| path =~ /\.gitignore$/ }.
    reject { |path| path =~ /^test\// }
  s.test_files       = `git ls-files -- {gemfiles,test}/*`.split("\n")
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
