3.5.3
===

Update blog_article active_support requires. Fixes #205

3.5.2
===

* Ignored pages won't be processed by the blog extension.
* Avoid creating an empty-string collection when a post does not have a custom collection property set. #192
* Fix blog sources matching blog entries that are in a subdirectory that's not explicitly stated as part of the blog.sources template. #196
* Fixed tag and year links in blog template. #195
* An article's language can be set via the {lang} parameter in its sources URL template. #187
* Tags that are just a number work now. #188

3.5.1
===

* Remove a broken bracket in the blog template. #181
* Fix transliteration of strings into URL slugs to still transliterate when it can but not smash multibyte chars. #183
* Only match source URI templates if the date components match what a date would look like, and avoid throwing when companion files do not have an article. #184
* Re-support spaces in blog article source paths. #185

3.5.0
===

* Add support for internationalization and locale-specific articles. #156
* Drop support for Ruby 1.8 and Middleman 3.0.
* Removed backwards compatibility patch that set instance variables for tag and calendar pages. Use locals instead.
* Templated paths like :sources, :taglink, :year_link, :month_link, :day_link, :page_link, and custom_collections links can now be optionally expressed as RFC 6570 URI templates.
* Arbitrary data from page frontmatter can be used in the :permalink template. Simply add a key to your :permalink template that matches a field from your frontmatter.
* Data extracted from the :sources URL template can be used in the :permalink template. This information can also be used from templates via current_article.metadata[:page][<key>].
* UTF-8 strings substituted into URLs are now preserved rather than being omitted. #176
* "middleman article" command now works even when there are multiple blogs. Specify the blog you want using "--blog".
* The template used to generate new articles via "middleman article" can be overridden by setting :new_article_template.
* Removed `:blog_name`, `:blog_author`, `:blog_avatar` options and the `page_title` helper.

3.4.1
====

* Require Middleman 3.2

3.4.0
====

* Add `inspect` methods to `BlogData` and `BlogArticle` to avoid hangs on exceptions. #157
* Generated feed.xml now works on blogs with no posts. #155
* No longer depend on `middleman-more`.
* Don't try to replace tokens that don't exist in the source path. #161
* Support for including arbitrary frontmatter data in blog permalinks. #164
* When using multiblog, fail immediately if the blog name isn't specified. #168

3.3.0
====

* Experimental support for multiple blogs in a single site by activating
  `:blog` multiple times.
* Works as a Middleman 3.1-style extension.
* Add `:blog_name`, `:blog_author`, `:blog_avatar` options and a `page_title` helper
  that incorporates `:blog_name`.
* Allow options.sources to contain the same date component multiple
  times. #112
* Improve `feed.xml.builder` template to support `blog.prefix`. #126
* Hide page numbers in template if only one page per index. #125
* URLs in the feed.xml template are now absolute. #130
* ASCII-8BIT text is reencoded to UTF-8 to avoid Nokogiri problems when
  generating summaries.
* `summary` will no longer explode when encountering comments in the
  article. #136
* Fix setting time zone with `set :time_zone` in `config.rb`. #140
* Articles can omit their :title from the filename and specify it in frontmatter
  instead. #148
* Pages can choose which blog to use in multi-blog mode by specifying the correct
  blog in frontmatter. #150

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
