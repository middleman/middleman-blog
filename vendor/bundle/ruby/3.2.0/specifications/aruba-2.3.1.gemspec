# -*- encoding: utf-8 -*-
# stub: aruba 2.3.1 ruby lib

Gem::Specification.new do |s|
  s.name = "aruba".freeze
  s.version = "2.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/cucumber/aruba/issues", "changelog_uri" => "https://www.rubydoc.info/gems/aruba/file/CHANGELOG.md", "documentation_uri" => "https://www.rubydoc.info/gems/aruba", "homepage_uri" => "https://github.com/cucumber/aruba", "source_code_uri" => "https://github.com/cucumber/aruba" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Aslak Helles\u00F8y, Matt Wynne and other Aruba Contributors".freeze]
  s.bindir = "exe".freeze
  s.date = "2025-06-14"
  s.description = "Extension for popular TDD and BDD frameworks like \"Cucumber\", \"RSpec\" and \"Minitest\",\nto make testing command line applications meaningful, easy and fun.\n".freeze
  s.email = "cukes@googlegroups.com".freeze
  s.executables = ["aruba".freeze]
  s.extra_rdoc_files = ["CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze, "README.md".freeze, "LICENSE".freeze]
  s.files = ["CHANGELOG.md".freeze, "CONTRIBUTING.md".freeze, "LICENSE".freeze, "README.md".freeze, "exe/aruba".freeze]
  s.homepage = "https://github.com/cucumber/aruba".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset".freeze, "UTF-8".freeze, "--main".freeze, "README.md".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 3.0.0".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "aruba-2.3.1".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<bundler>.freeze, [">= 1.17", "< 3.0"])
  s.add_runtime_dependency(%q<contracts>.freeze, [">= 0.16.0", "< 0.18.0"])
  s.add_runtime_dependency(%q<cucumber>.freeze, [">= 8.0", "< 11.0"])
  s.add_runtime_dependency(%q<rspec-expectations>.freeze, ["~> 3.4"])
  s.add_runtime_dependency(%q<thor>.freeze, ["~> 1.0"])
  s.add_development_dependency(%q<appraisal>.freeze, ["~> 2.4"])
  s.add_development_dependency(%q<diff-lcs>.freeze, ["~> 1.6"])
  s.add_development_dependency(%q<json>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<kramdown>.freeze, ["~> 2.1"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.10"])
  s.add_development_dependency(%q<rake>.freeze, [">= 12.0", "< 14.0"])
  s.add_development_dependency(%q<rake-manifest>.freeze, ["~> 0.2.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.11"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 1.76"])
  s.add_development_dependency(%q<rubocop-packaging>.freeze, ["~> 0.6.0"])
  s.add_development_dependency(%q<rubocop-performance>.freeze, ["~> 1.25"])
  s.add_development_dependency(%q<rubocop-rspec>.freeze, ["~> 3.6"])
  s.add_development_dependency(%q<simplecov>.freeze, [">= 0.18.0", "< 0.23.0"])
end
