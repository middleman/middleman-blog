# Middleman-Blog extension

middleman-blog is an extension for the [Middleman] static site generator that
adds blog-specific functionality. This includes :

- Handling blog articles
- Helpers for listing articles
- Tagging support

## Installation

If you're just getting started, install the `middleman` gem and generate a new
project:

```
gem install middleman
middleman init MY_PROJECT --template=blog
```

If you already have a Middleman project: Add `gem "middleman-blog"` to your
`Gemfile` and run `bundle install`

## Configuration

Within the config.rb of the middleman project, include the line

```
activate :blog
```

A more extensive guide can be found here :
[Middleman blogging guide](http://middlemanapp.com/basics/blogging/) it includes
more detailed information on configuring and using the blog extension.

Additionally, up-to-date generated code documentation is available on [RubyDoc].

## Build & Dependency Status

[![Gem Version](https://badge.fury.io/rb/middleman-blog.svg)][gem]
[![Build Status](https://travis-ci.org/middleman/middleman-blog.svg)][travis]
[![Dependency Status](https://gemnasium.com/middleman/middleman-blog.svg?travis)][gemnasium]
[![Code Quality](https://codeclimate.com/github/middleman/middleman-blog.svg)][codeclimate]
[![Code Coverage](https://coveralls.io/repos/middleman/middleman-blog/badge.svg?branch=master)][coveralls]

## Community

Please also visit the the official [Middleman community forum](http://forum.middlemanapp.com)

## Bug Reports

Github Issues are used for managing bug reports and feature requests.

If you run into issues or have an idea; please search and then submit the ticket
[here](https://github.com/middleman/middleman-blog/issues)

The best way to get quick responses to your issues and swift fixes to your bugs
is to submit detailed bug reports, include test cases and respond to developer
questions in a timely manner. Even better, if you know Ruby, you can submit
[Pull Requests](https://help.github.com/articles/using-pull-requests) containing
Cucumber Features which describe how your feature should work or exploit the bug
you are submitting.

## Testing

Our internal tests are passed through Travis, testing against the following
Ruby versions on Linux :

- ruby-head
- 2.4.0
- 2.3.1
- 2.2.4

### Running tests

1. Checkout Repository: `git clone https://github.com/middleman/middleman-blog.git`
2. Install Bundler: `gem install bundler`
3. Run `bundle install` inside the project root to install the gem dependencies.
4. Run test cases: `bundle exec rake test`

NB// To run an individual test use :

1. `bundle exec cucumber features/blog_sources.feature`

If you have suggestions for testing practices please submit a request.

## Creating documentation

1. `bundle exec rake doc`

## Donate

[Click here to lend your support to Middleman](https://plasso.com/s/4dXbHBorC3)

## License

Copyright (c) 2010-2017 Thomas Reynolds. MIT Licensed, see [LICENSE] for details.

[middleman]: http://middlemanapp.com
[gem]: https://rubygems.org/gems/middleman-blog
[travis]: http://travis-ci.org/middleman/middleman-blog
[gemnasium]: https://gemnasium.com/middleman/middleman-blog
[codeclimate]: https://codeclimate.com/github/middleman/middleman-blog
[coveralls]: https://coveralls.io/r/middleman/middleman-blog
[rubydoc]: http://rubydoc.info/github/middleman/middleman-blog/master
[LICENSE]: https://github.com/middleman/middleman-blog/blob/master/LICENSE.md
