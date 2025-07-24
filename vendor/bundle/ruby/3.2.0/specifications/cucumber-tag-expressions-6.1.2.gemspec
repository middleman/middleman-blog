# -*- encoding: utf-8 -*-
# stub: cucumber-tag-expressions 6.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "cucumber-tag-expressions".freeze
  s.version = "6.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 3.0.8".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/cucumber/cucumber/issues", "changelog_uri" => "https://github.com/cucumber/tag-expressions/blob/main/CHANGELOG.md", "documentation_uri" => "https://cucumber.io/docs/cucumber/api/#tag-expressions", "mailing_list_uri" => "https://groups.google.com/forum/#!forum/cukes", "source_code_uri" => "https://github.com/cucumber/tag-expressions/tree/main/ruby" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Andrea Nodari".freeze, "Aslak Helles\u00F8y".freeze]
  s.date = "2025-01-29"
  s.description = "Cucumber tag expressions for ruby".freeze
  s.email = "cukes@googlegroups.com".freeze
  s.homepage = "https://cucumber.io/docs/cucumber/api/#tag-expressions".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--charset=UTF-8".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "cucumber-tag-expressions-6.1.2".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, ["~> 13.1"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.11"])
  s.add_development_dependency(%q<rubocop>.freeze, ["~> 0.79.0"])
end
