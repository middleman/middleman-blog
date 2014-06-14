# -*- coding: utf-8 -*-
require 'active_support/time_with_zone'
require 'active_support/core_ext/time/acts_like'
require 'active_support/core_ext/time/calculations'

module Middleman
  module Blog
    # A module that adds blog-article-specific methods to Resources.
    # A {BlogArticle} can be retrieved via {Blog::Helpers#current_article} or
    # methods on {BlogData} (like {BlogData#articles}).
    # @see http://rdoc.info/github/middleman/middleman/Middleman/Sitemap/Resource Middleman::Sitemap::Resource
    module BlogArticle
      def self.extended(base)
        base.class.send(:attr_accessor, :blog_controller)
      end

      # A reference to the {BlogData} for this article's blog.
      # @return [BlogData]
      def blog_data
        blog_controller.data
      end

      # The options for this article's blog.
      # @return [ConfigurationManager]
      def blog_options
        blog_controller.options
      end

      # Render this resource to a string with the appropriate layout.
      # Called automatically by Middleman.
      # @return [String]
      def render(opts={}, locs={}, &block)
        if opts[:layout].nil?
          opts[:layout] = metadata[:options][:layout]
          opts[:layout] = blog_options.layout if opts[:layout].nil?
          # Convert to a string unless it's a boolean
          opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
        end

        content = super(opts, locs, &block)

        unless opts[:keep_separator]
          content.sub!(blog_options.summary_separator, "")
        end

        content
      end

      # The title of the article, set from frontmatter.
      # @return [String]
      def title
        data["title"]
      end

      # Whether or not this article has been published.
      #
      # An article is considered published in the following scenarios:
      #
      # 1. Frontmatter does not set +published+ to false and either
      # 2. The blog option +published_future_dated+ is true or
      # 3. The article's date is after the current time
      # @return [Boolean]
      def published?
        data["published"] != false && (blog_options.publish_future_dated || date <= Time.current)
      end

      # The body of this article, in HTML (no layout). This is for
      # things like RSS feeds or lists of articles - individual
      # articles will automatically be rendered from their
      # template.
      # @return [String]
      def body
        render layout: false
      end

      # The summary for this article, in HTML. The summary is either
      # everything before the summary separator (set via the blog option
      # +summary_separator+ and defaulting to "READMORE") or the first
      # +summary_length+ characters of the post.
      #
      # The blog option +summary_generator+ can be set to a +Proc+ in order to provide
      # custom summary generation. The +Proc+ is provided
      # the rendered content of the article (without layout), the
      # desired length to trim the summary to, and the ellipsis string to use.
      # Otherwise the {#default_summary_generator} will be used.
      #
      # @param [Number] length How many characters to trim the summary to.
      # @param [String] ellipsis The ellipsis string to use when content is trimmed.
      # @return [String]
      def summary(length=blog_options.summary_length, ellipsis='...')
        rendered = render layout: false, keep_separator: true

        if blog_options.summary_separator && rendered.match(blog_options.summary_separator)
          rendered.split(blog_options.summary_separator).first
        elsif blog_options.summary_generator
          blog_options.summary_generator.call(self, rendered, length, ellipsis)
        else
          default_summary_generator(rendered, length, ellipsis)
        end
      end

      # The default summary generator first tries to find the +summary_separator+ and
      # take the text before it. If that doesn't work, it will truncate text without splitting
      # the middle of an HTML tag, using a Nokogiri-based {TruncateHTML} utility.
      #
      # @param [String] rendered The rendered blog article
      # @param [Integer] length The length in characters to truncate to.
      #   -1 or +nil+ will return the whole article.
      def default_summary_generator(rendered, length, ellipsis)
        if blog_options.summary_separator && rendered =~ blog_options.summary_separator
          rendered.split(blog_options.summary_separator).first
        elsif length && length >= 0
          require 'middleman-blog/truncate_html'
          TruncateHTML.truncate_html(rendered, length, ellipsis)
        else
          rendered
        end
      end

      # A list of tags for this article, set from frontmatter.
      # @return [Array<String>] (never +nil+)
      def tags
        article_tags = data["tags"]

        if article_tags.is_a? String
          article_tags.split(',').map(&:strip)
        else
          Array(article_tags).map(&:to_s)
        end
      end

      # The language of the article. The language can be present in the
      # frontmatter or in the source path. If both are present, they
      # must match. If neither specifies a lang, I18n's default_locale will
      # be used. If +lang+ is set to nil, or the +:i18n+ extension is not
      # activated at all, +nil+ will be returned.
      #
      # @return [Symbol] Language code (for example, +:en+ or +:de+)
      def lang
        frontmatter_lang = data['lang']
        filename_lang = path_part('lang')

        if frontmatter_lang && filename_lang && frontmatter_lang != filename_lang
          raise "The lang in #{path}'s filename (#{filename_lang.inspect}) doesn't match the lang in its frontmatter (#{frontmatter_lang.inspect})"
        end

        locale_lang = I18n.default_locale if defined? I18n

        lang = frontmatter_lang || filename_lang || locale_lang
        lang && lang.to_sym
      end

      # Attempt to figure out the date of the post. The date should be
      # present in the source path, but users may also provide a date
      # in the frontmatter in order to provide a time of day for sorting
      # reasons.
      #
      # @return [TimeWithZone]
      def date
        return @_date if @_date

        frontmatter_date = data['date']

        # First get the date from frontmatter
        if frontmatter_date.is_a? Time
          @_date = frontmatter_date.in_time_zone
        else
          @_date = Time.zone.parse(frontmatter_date.to_s)
        end

        # Next figure out the date from the filename
        source_vars = blog_data.source_template.variables
        if source_vars.include?('year') &&
           source_vars.include?('month') &&
           source_vars.include?('day')

          filename_date = Time.zone.local(path_part('year').to_i, path_part('month').to_i, path_part('day').to_i)
          if @_date
            raise "The date in #{path}'s filename doesn't match the date in its frontmatter" unless @_date.to_date == filename_date.to_date
          else
            @_date = filename_date.to_time.in_time_zone
          end
        end

        raise "Blog post #{path} needs a date in its filename or frontmatter" unless @_date

        @_date
      end

      # The "slug" of the article that shows up in its URL. The article slug
      # is a parameterized version of the {#title} (lowercase, spaces replaced
      # with dashes, etc) and can be used in the blog +permalink+ as +:title+.
      #
      # @return [String]
      def slug
        if data['slug']
          data['slug']
        elsif blog_data.source_template.variables.include?('title')
          path_part('title')
        elsif title
          Blog::UriTemplates.safe_parameterize(title)
        else
          raise "Can't generate a slug for #{path} because it has no :title in its path pattern or title/slug in its frontmatter."
        end
      end

      # The previous (chronologically earlier) article before this one
      # or +nil+ if this is the first article.
      # @return [BlogArticle]
      def previous_article
        blog_data.articles.find {|a| a.date < self.date }
      end

      # The next (chronologically later) article after this one
      # or +nil+ if this is the most recent article.
      # @return [Middleman::Sitemap::Resource]
      def next_article
        blog_data.articles.reverse.find {|a| a.date > self.date }
      end

      # This is here to prevent out-of-memory on exceptions.
      # @private
      def inspect
        "#<Middleman::Blog::BlogArticle: #{data.inspect}>"
      end

      private

      # Retrieve a section of the source path template.
      # @param [String] part The part of the path, e.g. "lang", "year", "month", "day", "title"
      # @return [String]
      def path_part(part)
        @_path_parts ||= Blog::UriTemplates.extract_params(blog_data.source_template, path)
        @_path_parts[part.to_s]
      end
    end
  end
end
