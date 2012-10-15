require 'active_support/time_with_zone'
require 'active_support/core_ext/time/calculations'

module Middleman
  module Blog
    # A module that adds blog-article methods to Resources.
    module BlogArticle
      # Render this resource
      # @return [String]
      def render(opts={}, locs={}, &block)
        if opts[:layout].nil?
          if metadata[:options] && !metadata[:options][:layout].nil?
            opts[:layout] = metadata[:options][:layout]
          end
          opts[:layout] = app.blog.options.layout if opts[:layout].nil?
          opts[:layout] = opts[:layout].to_s if opts[:layout].is_a? Symbol
        end

        content = super(opts, locs, &block)

        unless opts[:keep_separator]
          if content =~ app.blog.options.summary_separator
            content.sub!(app.blog.options.summary_separator, "")
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
          (app.blog.options.publish_future_dated || date <= Time.current)
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
      # @return [String]
      def summary
        @_summary ||= begin
          source = app.template_data_for_file(source_file).dup

          summary_source = if app.blog.options.summary_generator
                             app.blog.options.summary_generator.call(self, source)
                           else
                             default_summary_generator(source)
                           end

          md   = metadata.dup
          locs = md[:locals]
          opts = md[:options].merge({:template_body => summary_source})
          app.render_individual_file(source_file, locs, opts)
        end
      end

      def default_summary_generator(source)
        if source =~ app.blog.options.summary_separator
          source.split(app.blog.options.summary_separator).first
        else
          source.match(/(.{1,#{app.blog.options.summary_length}}.*?)(\n|\Z)/m).to_s
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
      # @param [String] The part of the path, e.g. "year", "month", "day", "title"
      # @return [String]
      def path_part(part)
        @_path_parts ||= app.blog.path_matcher.match(path).captures

        @_path_parts[app.blog.matcher_indexes[part]]
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
        if app.blog.options.sources.include?(":year") &&
            app.blog.options.sources.include?(":month") &&
            app.blog.options.sources.include?(":day")

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
        @_slug ||= path_part("title")
      end

      # The previous (chronologically earlier) article before this one
      # or nil if this is the first article.
      # @return [Middleman::Sitemap::Resource]
      def previous_article
        app.blog.articles.find {|a| a.date < self.date }
      end
      
      # The next (chronologically later) article after this one
      # or nil if this is the most recent article.
      # @return [Middleman::Sitemap::Resource]
      def next_article
        app.blog.articles.reverse.find {|a| a.date > self.date }
      end
    end
  end
end
