# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org).

This document is formatted according to the principles of [Keep A CHANGELOG](http://keepachangelog.com).

Please visit [cucumber/CONTRIBUTING.md](https://github.com/cucumber/cucumber/blob/master/CONTRIBUTING.md) for more info on how to contribute to Cucumber.

## [Unreleased]

## [15.1.0] - 2025-02-28
### Changed
- Permit usage of gherkin up to v30

## [15.0.0] - 2024-12-24
### Changed
- Permit usage of messages up to v28

### Fixed
- References to the Time Conversion and UUID helpers needed altering to use the `Helpers` namespace

### Removed
- Remove support for ruby 2.7 and below. 3.0 or higher is required now (Owing to messages bump)

## [14.0.0] - 2024-08-08
### Changed
- Permit usage of gherkin up to v29 and messages up to v26
- **Internal Breaking Change**: Structure of `Action` classes have changed.
See upgrading notes for [14.0.0.md](upgrading_notes/14.0.0.md#upgrading-to-cucumber-core-1400)
([#282](https://github.com/cucumber/cucumber-ruby-core/pull/282))

### Removed
- Remove support for ruby 2.6 and below. 2.7 or higher is required now (Autofixed to Ruby 2.7 styles)

## [13.0.3] - 2024-07-24
### Changed
- Fixed up all remaining Layout autocorrect cops in the codebase

## [13.0.2] - 2024-03-21
### Changed
- Added CI testing for Ruby 3.3
- Fixed up a few minor rubocop offenses in the codebase around Array structuring

## [13.0.1] - 2024-01-31
### Changed
- Fixed up a few styling / layout cops in the tests

### Fixed
- The `Cucumber::Core::Test::Result::Passed` class was missing the strict keyword argument handling

## [13.0.0] - 2023-12-05
### Changed
- Now using a 2-tiered changelog to avoid any bugs when using polyglot-release
- More refactoring of the repo by fixing up a bunch of manual rubocop offenses (See PR's for details)
([#259](https://github.com/cucumber/cucumber-ruby-core/pull/259) [#262](https://github.com/cucumber/cucumber-ruby-core/pull/262) [#268](https://github.com/cucumber/cucumber-ruby-core/pull/268) [#274](https://github.com/cucumber/cucumber-ruby-core/pull/274))
- In all `Summary` and `Result` classes, changed the `strict` argument into a keyword argument.
See upgrading notes for [13.0.0.md](upgrading_notes/13.0.0.md#upgrading-to-cucumber-core-1300)
([#261](https://github.com/cucumber/cucumber-ruby-core/pull/261))
- Permit usage of gherkin v27

### Fixed
- Restore support for matching a scenario by its Feature, Background, and Rule line numbers ([#247](https://github.com/cucumber/cucumber-ruby-core/pull/247))

### Removed
- Remove legacy `unindent` gem (Now no longer required since Ruby 2.3 and Squiggly heredocs) ([#278](https://github.com/cucumber/cucumber-ruby-core/pull/278))

## [12.0.0] - 2023-09-06
### Changed
- Update gherkin and messages minimum dependencies
- Added in new rubocop sub-gems for testing, pinning versions where appropriate
- Removed all redundant / incorrect rubocop config overrides (Placed in TODO file)
- Began to refactor the repo by initially fixing up a bunch of rubocop auto-fix offenses (See PRs for details)
([#257](https://github.com/cucumber/cucumber-ruby-core/pull/257) [#258](https://github.com/cucumber/cucumber-ruby-core/pull/258))

### Removed
- Remove support for ruby 2.4 and below. 2.5 or higher is required now

## [11.1.0] - 2022-12-22
### Changed
- Update gherkin and messages dependencies

### Fixed
- Restore support for matching a scenario by tag and step line numbers. ([#237](https://github.com/cucumber/cucumber-ruby-core/pull/237), [#238](https://github.com/cucumber/cucumber-ruby-core/pull/238), [#239](https://github.com/cucumber/cucumber-ruby-core/pull/239))

## [11.0.0] - 2022-05-18
### Changed
- Updated `cucumber-gherkin` and `cucumber-messages`

[Unreleased]: https://github.com/cucumber/cucumber-ruby-core/compare/v15.1.0...HEAD
[15.1.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v15.0.0...v15.1.0
[15.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v14.0.0...v15.0.0
[14.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v13.0.3...v14.0.0
[13.0.3]: https://github.com/cucumber/cucumber-ruby-core/compare/v13.0.2...v13.0.3
[13.0.2]: https://github.com/cucumber/cucumber-ruby-core/compare/v13.0.1...v13.0.2
[13.0.1]: https://github.com/cucumber/cucumber-ruby-core/compare/v13.0.0...v13.0.1
[13.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v12.0.0...v13.0.0
[12.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v11.1.0...v12.0.0
[11.1.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v11.0.0...v11.1.0
[11.0.0]: https://github.com/cucumber/cucumber-ruby-core/compare/v10.1.1...v11.0.0
