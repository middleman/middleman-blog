require "date"

module Middleman
  module Extensions
    module Blog
      class << self
        def registered(app)
          app.set :blog_permalink, ":year/:month/:day/:title.html"
          app.set :blog_sources, ":year-:month-:day-:title.html"
          app.set :blog_taglink, "tags/:tag.html"
          app.set :blog_layout, "layout"
          app.set :blog_summary_separator, /(READMORE)/
          app.set :blog_summary_length, 250
          app.set :blog_year_link, ":year.html"
          app.set :blog_month_link, ":year/:month.html"
          app.set :blog_day_link, ":year/:month/:day.html"
          app.set :blog_default_extension, ".markdown"
            
          app.send :include, InstanceMethods

          app.after_configuration do
            # optional: :blog_tag_template
            # optional: :blog_year_template
            # optional: :blog_month_template
            # optional: :blog_day_template
            
            # Allow one setting to set all the calendar templates
            if respond_to? :blog_calendar_template
              set :blog_year_template, blog_calendar_template
              set :blog_month_template, blog_calendar_template
              set :blog_day_template, blog_calendar_template
            end

            matcher = Regexp.escape(blog_sources).
              sub(/^\//, "").
              sub(":year",  "(\\d{4})").
              sub(":month", "(\\d{2})").
              sub(":day",   "(\\d{2})").
              sub(":title", "(.*)")

            path_matcher = /^#{matcher}/
            file_matcher = /^#{source_dir}\/#{matcher}/

            sitemap.reroute do |destination, page|
              if page.path =~ path_matcher
                # This doesn't allow people to omit one part!
                year = $1
                month = $2
                day = $3
                title = $4

                # compute output path:
                #   substitute date parts to path pattern
                #   get date from frontmatter, path
                blog_permalink.
                  sub(':year', year).
                  sub(':month', month).
                  sub(':day', day).
                  sub(':title', title)
              else
                destination
              end
            end

            frontmatter_changed file_matcher do |file|
              blog.touch_file(file)
            end

            self.files.deleted file_matcher do |file|
              self.blog.remove_file(file)
            end

            provides_metadata file_matcher do
              {
                :options => {
                  :layout => blog_layout
                }
              }
            end
          end

          app.ready do
            # Set up tag pages if the tag template has been specified
            if defined? blog_tag_template
              page blog_tag_template, :ignore => true

              blog.tags.each do |tag, articles|
                page tag_path(tag), :proxy => blog_tag_template do
                  @tag = tag
                  @articles = articles
                end
              end
            end

            # Set up date pages if the appropriate templates have been specified
            blog.articles.group_by {|a| a.date.year }.each do |year, year_articles|
              if defined? blog_year_template
                page blog_year_template, :ignore => true

                page blog_year_path(year), :proxy => blog_year_template do
                  @year = year
                  @articles = year_articles
                end
              end
              
              year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
                if defined? blog_month_template
                  page blog_month_template, :ignore => true

                  page blog_month_path(year, month), :proxy => blog_month_template do
                    @year = year
                    @month = month
                    @articles = month_articles
                  end
                end
                
                month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
                  if defined? blog_day_template
                    page blog_day_template, :ignore => true

                    page blog_day_path(year, month, day), :proxy => blog_day_template do
                      @year = year
                      @month = month
                      @day = day
                      @articles = day_articles
                    end
                  end
                end
              end
            end
          end
        end
        alias :included :registered
      end

      # A store of all the blog articles in the site, with accessors
      # for the articles by various dimensions. Accessed via "blog" in
      # templates.
      class BlogData

        # @private
        def initialize(app)
          @app = app

          # A map from path to BlogArticle
          @_articles = {}
        end

        # A list of all blog articles, sorted by date
        # @return [Array<Middleman::Extensions::Blog::BlogArticle>]
        def articles
          @_sorted_articles ||= begin
            @_articles.values.sort do |a, b|
              b.date <=> a.date
            end
          end
        end

        # The BlogArticle for the given path, or nil if one doesn't exist.
        # @return [Middleman::Extensions::Blog::BlogArticle]
        def article(path)
          @_articles[path.to_s]
        end

        # Returns a map from tag name to an array
        # of BlogArticles associated with that tag.
        # @return [Hash<String, Array<Middleman::Extensions::Blog::BlogArticle>>]
        def tags
          @tags ||= begin
            tags = {}
            @_articles.values.each do |article|
              article.tags.each do |tag|
                tags[tag] ||= []
                tags[tag] << article
              end
            end

            tags
          end
        end

        # Notify the blog store that a particular file has updated
        # @private
        def touch_file(file)
          output_path = @app.sitemap.file_to_path(file)
          if @app.sitemap.exists?(output_path)
            if @_articles.has_key?(output_path)
              @_articles[output_path].update!
            else
              @_articles[output_path] = BlogArticle.new(@app, @app.sitemap.page(output_path))
            end

            self.update_data
          end
        end

        # Notify the blog store that a file has been removed
        # @private
        def remove_file(file)
          output_path = @app.sitemap.file_to_path(file)

          if @_articles.has_key?(output_path)
            @_articles.delete(output_path)
            self.update_data
          end
        end

      protected
        # Clear cached data
        # @private
        def update_data
          @_sorted_articles = nil
          @tags = nil
        end
      end

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

      module InstanceMethods
        # Get the {BlogData} for this site.
        # @return [BlogData]
        def blog
          @_blog ||= BlogData.new(self)
        end

        # Determine whether the currently rendering template is a blog article.
        # This can be useful in layouts.
        # @return [Boolean]
        def is_blog_article?
          !current_article.nil?
        end

        # Get a {BlogArticle} representing the current article.
        # @return [BlogArticle]
        def current_article
          blog.article(current_page.path)
        end

        # Get a path to the given tag, based on the :blog_taglink setting.
        # @param [String] tag
        # @return [String]
        def tag_path(tag)
          blog_taglink.sub(':tag', tag.parameterize)
        end

        # Get a path to the given year-based calendar page, based on the :blog_year_link setting.
        # @param [Number] year
        # @return [String]
        def blog_year_path(year)
          blog_year_link.sub(':year', year.to_s)
        end

        # Get a path to the given month-based calendar page, based on the :blog_month_link setting.
        # @param [Number] year        
        # @param [Number] month
        # @return [String]
        def blog_month_path(year, month)
          blog_month_link.sub(':year', year.to_s).
            sub(':month', month.to_s.rjust(2,'0'))
        end

        # Get a path to the given day-based calendar page, based on the :blog_day_link setting.
        # @param [Number] year        
        # @param [Number] month
        # @param [Number] day
        # @return [String]
        def blog_day_path(year, month, day)
          blog_day_link.sub(':year', year.to_s).
            sub(':month', month.to_s.rjust(2,'0')).
            sub(':day', day.to_s.rjust(2,'0'))
        end
      end
    end
  end
end
