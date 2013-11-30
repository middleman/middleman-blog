# Middleman-Blog

`middleman-blog` is an extension for the [Middleman] static site generator that adds blog-specific functionality. This includes handling blog articles, helpers for listing articles, and tagging support.

## Installation

If you're just getting started, install the `middleman` gem and generate a new project:

```
gem install middleman
middleman init MY_PROJECT
```

If you already have a Middleman project: Add `gem "middleman-blog"` to your `Gemfile` and run `bundle install`

## Configuration

```
activate :blog
```

## Learn More

See [the blog extension guide](http://middlemanapp.com/basics/blogging/) for detailed information on configuring and using the blog extension.

Additionally, up-to-date generated code documentation is available on [RubyDoc].

## Build & Dependency Status

[![Gem Version](https://badge.fury.io/rb/middleman-blog.png)][gem]
[![Build Status](https://travis-ci.org/middleman/middleman-blog.png)][travis]
[![Dependency Status](https://gemnasium.com/middleman/middleman-blog.png?travis)][gemnasium]
[![Code Quality](https://codeclimate.com/github/middleman/middleman-blog.png)][codeclimate]
[![Code Coverage](https://coveralls.io/repos/middleman/middleman-blog/badge.png?branch=master)][coveralls]
## Community

The official community forum is available at: http://forum.middlemanapp.com

## Bug Reports

Github Issues are used for managing bug reports and feature requests. If you run into issues, please search the issues and submit new problems: https://github.com/middleman/middleman-blog/issues

The best way to get quick responses to your issues and swift fixes to your bugs is to submit detailed bug reports, include test cases and respond to developer questions in a timely manner. Even better, if you know Ruby, you can submit [Pull Requests](https://help.github.com/articles/using-pull-requests) containing Cucumber Features which describe how your feature should work or exploit the bug you are submitting.

## How to Run Cucumber Tests

1. Checkout Repository: `git clone https://github.com/middleman/middleman-blog.git`
2. Install Bundler: `gem install bundler`
3. Run `bundle install` inside the project root to install the gem dependencies.
4. Run test cases: `bundle exec rake test`

## Donate

[Click here to lend your support to Middleman](https://spacebox.io/s/4dXbHBorC3)

## License

Copyright (c) 2010-2013 Thomas Reynolds. MIT Licensed, see [LICENSE] for details.

[middleman]: http://middlemanapp.com
[gem]: https://rubygems.org/gems/middleman-blog
[travis]: http://travis-ci.org/middleman/middleman-blog
[gemnasium]: https://gemnasium.com/middleman/middleman-blog
[codeclimate]: https://codeclimate.com/github/middleman/middleman-blog
[coveralls]: https://coveralls.io/r/middleman/middleman-blog
[rubydoc]: http://rubydoc.info/github/middleman/middleman-blog
[LICENSE]: https://github.com/middleman/middleman-blog/blob/master/LICENSE.md
