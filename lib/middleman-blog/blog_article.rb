require 'active_support/time_with_zone'
require 'active_support/core_ext/time/calculations'

module Middleman
  module Blog
    # A module that adds blog-article methods to Resources.
    module BlogArticle
      def self.extended(base)
        base.class.send(:attr_accessor, :blog_controller)
      end

      def blog_data
        if self.blog_controller
          self.blog_controller.data
        else
          app.blog
        end
      end

      def blog_options
        if self.blog_controller
          self.blog_controller.options
        else
          app.blog.options
        end
      end

      # Render this resource
      # @return [String]
      def render(opts={}, locs={}, &block)
        if opts[:layout].nil?
          if metadata[:options] && !metadata[:options][:layout].nil?
            opts[:layout] = metadata[:options][:layout]
          end
          opts[:layout] = blog_options.layout if opts[:layout].nil?
          opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
        end

        content = super(opts, locs, &block)

        unless opts[:keep_separator]
          if content.match(blog_options.summary_separator)
            content.sub!(blog_options.summary_separator, "")
          end
        end

        content
      end

      # The title of the article, set from frontmatter
      # @return [String]
      def title
        data["title"]
      end

      # Whether or not this article has been published
      #
      # An article is considered published in the following scenarios:
      #
      # 1. frontmatter does not set published to false and either
      # 2. published_future_dated is true or
      # 3. article date is after the current time
      # @return [Boolean]
      def published?
        (data["published"] != false) and
          (blog_options.publish_future_dated || date <= Time.current)
      end

      # The body of this article, in HTML. This is for
      # things like RSS feeds or lists of articles - individual
      # articles will automatically be rendered from their
      # template.
      # @return [String]
      def body
        render(:layout => false)
      end

      # The summary for this article, in HTML. The summary is either
      # everything before the summary separator (set via :summary_separator
      # and defaulting to "READMORE") or the first :summary_length
      # characters of the post.
      #
      # :summary_generator can be set to a Proc in order to provide
      # custom summary generation. The Proc is provided a parameter
      # which is the rendered content of the article (without layout), the
      # desired length to trim the summary to, and the ellipsis string to use.
      #
      # @param [Number] length How many characters to trim the summary to.
      # @param [String] ellipsis The ellipsis string to use when content is trimmed.
      # @return [String]
      def summary(length=blog_options.summary_length, ellipsis='...')
        rendered = render(:layout => false, :keep_separator => true)

        if blog_options.summary_separator && rendered.match(blog_options.summary_separator)
          rendered.split(blog_options.summary_separator).first
        elsif blog_options.summary_generator
          blog_options.summary_generator.call(self, rendered, length, ellipsis)
        else
          default_summary_generator(rendered, length, ellipsis)
        end
      end

      def default_summary_generator(rendered, length, ellipsis)
        require 'middleman-blog/truncate_html'

        if rendered =~ blog_options.summary_separator
          rendered.split(blog_options.summary_separator).first
        elsif length
          TruncateHTML.truncate_html(rendered, length, ellipsis)
        else
          rendered
        end
      end

      # A list of tags for this article, set from frontmatter.
      # @return [Array<String>] (never nil)
      def tags
        article_tags = data["tags"]

        if article_tags.is_a? String
          article_tags.split(',').map(&:strip)
        else
          article_tags || []
        end
      end

      # Retrieve a section of the source path
      # @param [String] The part of the path, e.g. "lang", "year", "month", "day", "title"
      # @return [String]
      def path_part(part)
        @_path_parts ||= blog_data.path_matcher.match(path).captures
        @_path_parts[blog_data.matcher_indexes[part]]
      end

      # The language of the article. The language can be present in the
      # frontmatter or in the source path. If both labels present, they
      # must match. If none labels present, I18n's default_locale will
      # be returned. If it is set to nil, or i18n extension is not
      # activated at all, :none will be returned.
      #
      # @return [Symbol]
      def lang
        return @_lang if @_lang

        frontmatter_lang = data["lang"]

        if blog_options.sources.include? ":lang"
          filename_lang = path_part "lang"
          raise "The lang in #{path}'s filename doesn't match the lang in its frontmatter" if frontmatter_lang and filename_lang and not frontmatter_lang == filename_lang
        end

        if defined? I18n
          locale_lang = I18n.default_locale
        end

        lang = frontmatter_lang || filename_lang || locale_lang || :none
        lang = lang.to_sym if lang.kind_of? String

        @_lang = lang
      end

      # Normalize information about article's language in it's metadata
      def normalize_lang!
        return false if lang == :none
        data = { :lang => lang }
        add_metadata(:options => data, :locals => data){ @lang = @_lang }
        return true
      end

      # Attempt to figure out the date of the post. The date should be
      # present in the source path, but users may also provide a date
      # in the frontmatter in order to provide a time of day for sorting
      # reasons.
      #
      # @return [TimeWithZone]
      def date
        return @_date if @_date

        frontmatter_date = data["date"]

        # First get the date from frontmatter
        if frontmatter_date.is_a? Time
          @_date = frontmatter_date.in_time_zone
        else
          @_date = Time.zone.parse(frontmatter_date.to_s)
        end

        # Next figure out the date from the filename
        if blog_options.sources.include?(":year") &&
            blog_options.sources.include?(":month") &&
            blog_options.sources.include?(":day")

          filename_date = Time.zone.local(path_part("year").to_i, path_part("month").to_i, path_part("day").to_i)
          if @_date
            raise "The date in #{path}'s filename doesn't match the date in its frontmatter" unless @_date.to_date == filename_date.to_date
          else
            @_date = filename_date.to_time.in_time_zone
          end
        end

        raise "Blog post #{path} needs a date in its filename or frontmatter" unless @_date

        @_date
      end

      # The "slug" of the article that shows up in its URL.
      # @return [String]
      def slug
        @_slug ||= data["slug"]

        @_slug ||= if blog_options.sources.include?(":title")
          path_part("title")
        elsif title
          title.parameterize
        else
          raise "Can't generate a slug for #{path} because it has no :title in its path pattern or title/slug in its frontmatter."
        end
      end

      # The previous (chronologically earlier) article before this one
      # or nil if this is the first article.
      # @return [Middleman::Sitemap::Resource]
      def previous_article
        blog_data.articles.find {|a| a.date < self.date }
      end

      # The next (chronologically later) article after this one
      # or nil if this is the most recent article.
      # @return [Middleman::Sitemap::Resource]
      def next_article
        blog_data.articles.reverse.find {|a| a.date > self.date }
      end

      def inspect
        "#<Middleman::Blog::BlogArticle: #{data.inspect}>"
      end
    end
  end
end
