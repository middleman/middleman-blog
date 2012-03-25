require 'date'

module Middleman
  module Blog
    # A class encapsulating the properties of a blog article.
    # Access the underlying page object with {#page}.
    class BlogArticle
      # The {http://rubydoc.info/github/middleman/middleman/master/Middleman/Sitemap/Page Page} associated with this article.
      # @return [Middleman::Sitemap::Page]
      attr_reader :page

      # The date for this article, set from the filename 
      # (and optionally refined by frontmatter)
      # @return [DateTime]
      attr_reader :date

      # The title of the article, set from frontmatter
      # @return [String]
      attr_reader :title

      # @private
      def initialize(app, page)
        @app  = app
        @page = page

        self.update!
      end

      # @private
      def update!
        data, content = @app.frontmatter(@page.relative_path)

        @title = data["title"]
        @_raw  = content

        find_date

        @_body = nil
        @_summary = nil
      end

      # The permalink url for this blog article.
      # @return [String]
      def url
        @page.url
      end

      # The body of this article, in HTML. This is for
      # things like RSS feeds or lists of articles - individual
      # articles will automatically be rendered from their
      # template.
      # @return [String]
      def body
        @_body ||= begin
          all_content = @page.render(:layout => false)

          if all_content =~ @app.blog_summary_separator
            all_content.sub!($1, "")
          end

          all_content
        end
      end

      # The summary for this article, in HTML. The summary is either
      # everything before the summary separator (set via :blog_summary_separator
      # and defaulting to "READMORE") or the first :blog_summary_length
      # characters of the post.
      # @return [String]
      def summary
        @_summary ||= begin
          sum = if @_raw =~ @app.blog_summary_separator
            @_raw.split(@app.blog_summary_separator).first
          else
            @_raw.match(/(.{1,#{@app.blog_summary_length}}.*?)(\n|\Z)/m).to_s
          end

          engine = ::Tilt[@page.source_file].new { sum }
          engine.render
        end
      end

      # A list of tags for this article, set from frontmatter.
      # @return [Array<String>] (never nil)
      def tags
        article_tags = @page.data["tags"]

        if article_tags.is_a? String
          article_tags.split(',').map(&:strip)
        else
          article_tags || []
        end
      end

      private

      # Attempt to figure out the date of the post. The date should be
      # present in the source path, but users may also provide a date
      # in the frontmatter in order to provide a time of day for sorting
      # reasons.
      def find_date
        frontmatter_date = @page.data["date"]

        # First get the date from frontmatter
        if frontmatter_date.is_a?(String)
          @date = DateTime.parse(frontmatter_date)
        else
          @date = frontmatter_date
        end

        # Next figure out the date from the filename
        if @app.blog_sources.include?(":year") &&
            @app.blog_sources.include?(":month") &&
            @app.blog_sources.include?(":day")
          date_parts = BlogData.matcher.match(@page.path).captures

          filename_date = Date.new(date_parts[0].to_i, date_parts[1].to_i, date_parts[2].to_i)
          if @date
            raise "The date in #{@page.path}'s filename doesn't match the date in its frontmatter" unless @date.to_date == filename_date
          else
            @date = filename_date.to_datetime
          end
        end

        raise "Blog post #{@page.path} needs a date in its filename or frontmatter" unless @date
      end
    end
  end
end
