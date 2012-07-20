require 'date'

module Middleman
  module Blog
    # A module that adds blog-article methods to Resources.
    module BlogArticle
      # Render this resource
      # @return [String]
      def render(opts={}, locs={}, &block)
        opts[:layout] = app.blog.options.layout if opts[:layout].nil?

        content = super(opts, locs, &block)

        unless opts[:keep_separator]
          if content =~ app.blog.options.summary_separator
            content.sub!($1, "")
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
      # @return [Boolean]
      def published?
        data["published"] != false
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
          all_content = render(:layout => false, :keep_separator => true)
          if all_content =~ app.blog.options.summary_separator
            all_content.split(app.blog.options.summary_separator).first
          else
            all_content.match(/(.{1,#{app.blog.options.summary_length}}.*?)(\n|\Z)/m).to_s
          end
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
      # @return [DateTime]
      def date
        return @_date if @_date

        frontmatter_date = data["date"]

        # First get the date from frontmatter
        if frontmatter_date.is_a?(String)
          @_date = DateTime.parse(frontmatter_date)
        else
          @_date = frontmatter_date
        end

        # Next figure out the date from the filename
        if app.blog.options.sources.include?(":year") &&
            app.blog.options.sources.include?(":month") &&
            app.blog.options.sources.include?(":day")

          filename_date = Date.new(path_part("year").to_i, path_part("month").to_i, path_part("day").to_i)
          if @_date
            raise "The date in #{path}'s filename doesn't match the date in its frontmatter" unless @_date.to_date == filename_date
          else
            @_date = filename_date.to_datetime
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
