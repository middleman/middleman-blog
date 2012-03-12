require "date"

module Middleman
  module Extensions
    module Blog
      class << self
        def registered(app)
          app.send :include, InstanceMethods

          app.after_configuration do
            if !respond_to? :blog_permalink
              set :blog_permalink, ":year/:month/:day/:title.html"
            end

            if !respond_to? :blog_taglink
              set :blog_taglink, "tags/:tag.html"
            end

            if !respond_to? :blog_layout
              set :blog_layout, "layout"
            end

            if !respond_to? :blog_summary_separator
              set :blog_summary_separator, /(READMORE)/
            end

            if !respond_to? :blog_summary_length
              set :blog_summary_length, 250
            end

            # optional: :blog_tag_template

            matcher = blog_permalink.dup
            matcher.sub!(":year",  "(\\d{4})")
            matcher.sub!(":month", "(\\d{2})")
            matcher.sub!(":day",   "(\\d{2})")
            matcher.sub!(":title", "(.*)")
            BlogData.matcher = %r{#{source}/#{matcher}}

            frontmatter_changed BlogData.matcher do |file|
              blog.touch_file(file)
            end

            self.files.deleted BlogData.matcher do |file|
              self.blog.remove_file(file)
            end

            provides_metadata BlogData.matcher do
              {
                :options => {
                  :layout => blog_layout,
                }
              }
            end
          end

          app.ready do
            puts "== Blog: #{blog_permalink}" unless build?
          end
        end
        alias :included :registered
      end

      class BlogData
        class << self
          attr_accessor :matcher
        end

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

        # The BlogArticle for the given path, or nil
        # @return [Middleman::Extensions::Blog::BlogArticle]
        def article(path)
          @_articles[path.to_s]
        end

        # Returns a map from tag name to an array
        # of BlogArticles associated with that tag.
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
        def remove_file(file)
          output_path = @app.sitemap.file_to_path(file)

          if @_articles.has_key?(output_path)
            @_articles.delete(output_path)
            self.update_data
          end
        end

      protected
        # Clear cached data
        def update_data
          @_sorted_articles = nil
          @tags = nil
        end
      end

      # A class encapsulating the properties of a blog article.
      # Access the underlying page object with "page"
      class BlogArticle
        attr_accessor :page, :date, :title, :raw, :summary, :frontmatter

        def initialize(app, page)
          @app  = app
          @page = page

          self.update!
        end

        def update!
          path = @page.source_file.sub(@app.source_dir, "")
          data, content = @app.frontmatter(path)

          if data && data["date"] && data["date"].is_a?(String)
            if data["date"].match(/\d{4}\/\d{2}\/\d{2}/)
              self.date = Date.strptime(data["date"], '%Y/%m/%d')
            elsif data["date"].match(/\d{2}\/\d{2}\/\d{4}/)
              self.date = Date.strptime(data["date"], '%m/%d/%Y')
            end
          end

          self.frontmatter = data
          self.title       = data["title"] if data
          self.raw         = content

          @_body = nil
          @_summary = nil
        end

        def url
          @page.url
        end

        def body
          @_body ||= begin
            all_content = @page.render(:layout => false)

            if all_content =~ @app.blog_summary_separator
              all_content.sub!($1, "")
            end

            all_content
          end
        end

        def summary
          @_summary ||= begin
            sum = if self.raw =~ @app.blog_summary_separator
              self.raw.split(@app.blog_summary_separator).first
            else
              self.raw.match(/(.{1,#{@app.blog_summary_length}}.*?)(\n|\Z)/m).to_s
            end

            engine = ::Tilt[@page.source_file].new { sum }
            engine.render
          end
        end

        def tags
          article_tags = frontmatter["tags"]
          [] if article_tags.blank?

          if article_tags.is_a? String
            article_tags.split(',').map(&:strip)
          else
            article_tags || []
          end
        end
      end

      module InstanceMethods
        def blog
          @_blog ||= BlogData.new(self)
        end

        def is_blog_article?
          !current_article.nil?
        end

        def current_article
          blog.article(current_page.path)
        end
      end
    end
  end
end
