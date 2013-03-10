3.2.0
====

* The `summary` method on articles is now HTML-aware, and can be provided with
  a different summary length or ellipsis string: `summary(1000, '&hellip;')`. 
  Nokogiri is required to use the summary.
* The `summary_generator` option now recieves the rendered article (without
  layout) instead of the template source.
* Set `summary_length` to false to always use the full article as a summary.
* Future-dated articles can still be generated if `publish_future_dated` is true.
* The `summary_separator` option no longer needs to have a capturing group, or
  even be a regexp.

3.1.1
====
* Correctly handle time zone, allow setting time zone with `set :time_zone`. #76
* Fix using `page_articles` in when `paginate` is false. #78

3.1.0
====
* Don't publish future-dated articles. #74
* Create summary from source instead of output. #70
* Deprecate instance variables in templates in favor of locals. #66
* Allow articles to set "published: false" in frontmatter and show up in preview but not in build/production.
* Allow articles to have their own layout set in the YAML front matter. #59
* Per-article content subdirectories. #60
* Allow article date to be in any order in permalink. #60
* Use `link_to` in blog templates. #62
* Pagination for index, tag, and calendar pages. #57

3.0.0
====
* Middleman-3.0 compatible release. Complete overhaul.
* Tag and calendar pages.
* Sitemap integration.
* Lots of bugfixes.
