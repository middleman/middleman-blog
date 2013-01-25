# middleman-blog

middleman-blog is an extension for the [Middleman](http://middlemanapp.com) static site generator that adds blog-specific functionality. This includes handling blog articles, helpers for listing articles, and tagging support.

# Install
If you're just getting started, install the `middleman` and `middleman-blog` gems and generate a new project:

```
gem install middleman
gem install middleman-blog
middleman init MY_BLOG_PROJECT --template=blog
```

If you already have a Middleman project:
Add `middleman-blog` to your `Gemfile`, and open your `config.rb` and add:

```
activate :blog
```

# Learn More

See [the blog extension guide](http://middlemanapp.com/blogging/) for detailed information on configuring and using the blog extension.

Up-to-date generated code documentation is available on RubyDoc: 
http://rubydoc.info/github/middleman/middleman-blog

# Community

The official community forum is available at:

  http://forum.middlemanapp.com/

# Bug Reports

GitHub Issues are used for managing bug reports and feature requests. If you run into issues, please search the issues and submit new problems:

https://github.com/middleman/middleman-blog/issues

The best way to get quick responses to your issues and swift fixes to your bugs is to submit detailed bug reports, include test cases and respond to developer questions in a timely manner. Even better, if you know Ruby, you can submit Pull Requests containing Cucumber Features which describe how your feature should work or exploit the bug you are submitting.

# Build & Dependency Status

[![Build Status](https://travis-ci.org/middleman/middleman-blog.png)](https://travis-ci.org/middleman/middleman-blog)

# How to Run Cucumber Tests

1. Checkout Repository: `git clone https://github.com/middleman/middleman-blog.git`
2. Install Bundler: `gem install bundler`
3. Run `bundle install` inside the project root to install the gem dependencies.
4. Run test cases: `bundle exec rake test`

# Donate

Please, [help support the Middleman team with a donation](https://spb.io/s/4dXbHBorC3).

# License

Copyright (c) 2010 Thomas Reynolds. MIT Licensed, see [LICENSE] for details.

[LICENSE]: https://github.com/middleman/middleman-blog/blob/master/LICENSE
