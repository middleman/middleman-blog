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

            if !respond_to? :blog_layout_engine
              set :blog_layout_engine, "erb"
            end

            if !respond_to? :blog_index_template
              set :blog_index_template, "index_template"
            end

            if !respond_to? :blog_article_template
              set :blog_article_template, "article_template"
            end

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
                  :layout        => blog_layout,
                  :layout_engine => blog_layout_engine
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
          @_articles = {}
        end

        def articles
          @_sorted_articles ||= begin
            @_articles.values.sort do |a, b|
              b.date <=> a.date
            end
          end
        end

        def article(path)
          if @_articles.has_key?(path.to_s)
            @_articles[path.to_s]
          else
            nil
          end
        end

        def tags
          @tags ||= begin
            tags = {}
            @_articles.values.each do |article|
              next unless article.frontmatter.has_key?("tags")

              article_tags = article.frontmatter["tags"]
              next if article_tags.empty?

              tags_array = article_tags.split(',').map { |t| t.strip }
              tags_array.each do |tag_title|
                tag_key = tag_title.parameterize
                tag_path = @app.blog_taglink.gsub(/(:\w+)/, tag_key)
                (tags[tag_path] ||= {})["title"] = tag_title
                tags[tag_path]["ident"] = tag_key
                (tags[tag_path]["pages"] ||= {})[article.title] = article.url
              end

              tags
            end
          end
        end

        def touch_file(file)
          output_path = @app.sitemap.file_to_path(file)
          if @app.sitemap.exists?(output_path)
            if @_articles.has_key?(output_path)
              @_articles[output_path].update!
            else
              @_articles[output_path] = BlogArticle.new(@app, @app.sitemap.page(output_path))
            end
          end

          self.update_data
        end

        def remove_file(file)
          output_path = @app.sitemap.file_to_path(file)

          if @_articles.has_key?(output_path)
            @_articles.delete(output_path)
            self.update_data
          end
        end

      protected
        def update_data
          @_sorted_articles = nil
          @tags = nil
        end
      end

      class BlogArticle
        attr_accessor :date, :title, :raw, :url, :summary, :frontmatter

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
          self.title       = data["title"]
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

        # def to_h
        #   {
        #     :date    => self.date,
        #     :raw     => self.raw,
        #     :url     => self.url,
        #     :body    => self.body,
        #     :title   => self.title,
        #     :summary => self.summary
        #   }
        # end
      end

      module InstanceMethods
        def blog
          @_blog ||= BlogData.new(self)
        end

        def is_blog_article?
          !current_article.nil?
        end

        # def blog_title
        # end

        def current_article_date
          current_article.date
        end

        def current_article_title
          current_article.title
        end

        def current_article
          blog.article(current_page.path)
        end

        def current_article_tags
          article_tags_hash = {}
          if is_blog_article? && current_article.tags
            article_tags = current_article.tags.split(',').map{|t| t.strip}
            article_tags.each do |tag_title|
              article_tags_hash[tag_title] = self.blog_taglink.gsub(/(:\w+)/, tag_title.parameterize)
            end
          end
          article_tags_hash
        end

        def blog_tags
          blog.tags
        end

        def current_tag
          blog.tags[request.path]
        end

        def current_tag_articles
          blog.articles.map do |article|
            article if current_tag.pages.has_value?(article.url)
          end.compact
        end

        def current_tag_title
          current_tag_data.title
        end
      end
    end
  end
end
