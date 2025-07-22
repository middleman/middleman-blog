# Changelog

## [Unreleased]

## [1.1.0] - 2022-05-11
### Added
- `MultiTest.disable_autorun` is back again!
([#33](https://github.com/cucumber/multi_test/issues/33)
[#26](https://github.com/cucumber/multi_test/issues/26))

## [1.0.0] - 2022-05-04
### Changed
- As per [#251](https://github.com/cucumber/cucumber/issues/251): renamed History.md to CHANGELOG.md, added contributing message at beginning, and other formatting. ([#12](https://github.com/cucumber/multi_test/pull/12) [jaysonesmith](https://github.com/jaysonesmith/))

### Removed
- Remove test files from the gem to prevent false-positive with security scanners
as reported in [#21](https://github.com/cucumber/multi_test/issues/21)
- Drop support for ruby < 2.0
([PR#28](https://github.com/cucumber/multi_test/pull/28))
- Removed `disable_autorun`
([PR#30](https://github.com/cucumber/multi_test/pull/30)
[Issue#26](https://github.com/cucumber/multi_test/issues/26))

## [0.1.2]
### Changed
- Ensure that detecting assetion library doesn't fail if no test framework
included. Ruby 2.2 removed minitest from standard library. (@tooky, @jmoody)

## [0.1.1]
### Removed
- Remove incompatibility with ruby 1.8.7

## [0.1.0]
### Added
- Detect best available assertion library for cucumber (@tooky)

## [0.0.3]
### Fixed
- Fix for Rails 4.1, Minitest 5.x ([#4](https://github.com/cucumber/multi_test/pull/4) Andy Lindeman)

## [0.0.2]
### Changed
- First gem release

[Unreleased]: https://github.com/cucumber/multi_test/compare/1.0.0..main
[1.1.0]: https://github.com/cucumber/multi_test/compare/1.0.0..main
[1.0.0]: https://github.com/cucumber/multi_test/compare/v0.1.2..main
[0.1.2]: https://github.com/cucumber/multi_test/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/cucumber/multi_test/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/cucumber/multi_test/compare/v0.0.3...v0.1.0
[0.0.3]: https://github.com/cucumber/multi_test/compare/v0.0.2...v0.0.3
[0.0.2]: https://github.com/cucumber/multi_test/compare/bae4b700eb63cfb4e95f7acc35e25683f697905a...v0.0.2
