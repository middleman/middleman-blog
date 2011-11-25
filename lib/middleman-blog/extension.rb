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
              set :blog_summary_separator, /READMORE/
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

            file_changed BlogData.matcher do |file|
              blog.touch_file(file)
            end

            file_deleted BlogData.matcher do |file|
              blog.remove_file(file)
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
          @articles = {}
        end
        
        def sorted_articles
          @sorted_articles ||= begin
            @articles.values.sort do |a, b|
              b.date <=> a.date
            end
          end
        end
        
        def tags
          @tags ||= begin
            tags = {}
            @articles.values.each do |article|
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
            if @articles.has_key?(file)
              @articles[file].update!
            else
              @articles[file] = BlogArticle.new(@app, @app.sitemap.page(output_path))
            end
          end
          
          self.update_data
        end
      
        def remove_file(file)
          if @articles.has_key?(file)
            @articles.delete(file)
            self.update_data
          end
        end
        
      protected
        def update_data
          @sorted_articles = false
          @tags = false
          
          @app.data_content("blog", {
            :articles => self.sorted_articles.map(&:to_h), 
            :tags     => self.tags
          })
        end
      end
      
      class BlogArticle
        attr_accessor :date, :title, :raw, :url, :summary, :frontmatter
        
        def initialize(app, page)
          @app  = app
          @page = page
          
          @page.custom_renderer do
            "Hi mom"
          end
          
          template_content = @app.cache.get([:raw_template, page.source_file])
          
          data, content = app.frontmatter.data(page.source_file.sub(@app.source_dir, ""))
          
          if data && data["date"] && data["date"].is_a?(String)
            if data["date"].match(/\d{4}\/\d{2}\/\d{2}/)
              self.date = Date.strptime(data["date"], '%Y/%m/%d')
            elsif data["date"].match(/\d{2}\/\d{2}\/\d{4}/)
              self.date = Date.strptime(data["date"], '%d/%m/%Y')
            end
          end
        
          self.frontmatter = data
          self.title       = data["title"]
          self.raw         = content
          self.url         = page.path
          
          self.update!
        end
        
        def update!
          @_body = nil
          @_summary = nil
        end
        
        def body
          @_body ||= begin
            all_content = @page.render(:layout => false)
            all_content.sub(@app.blog_summary_separator, "")
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
      
        def to_h
          {
            :date    => self.date,
            :raw     => self.raw,
            :url     => self.url,
            :body    => self.body,
            :title   => self.title,
            :summary => self.summary
          }
        end
      end
      
      module InstanceMethods
        def blog
          @_blog ||= BlogData.new(self)
        end
        
        def is_blog_article?
          !current_article_title.blank?
        end
      
        def blog_title
        end
      
        def current_article_date
          DateTime.parse("#{current_article_metadata.date}")
        end
      
        def current_article_title
          current_article_metadata.title
        end
      
        def current_article_metadata
          data.page
        end
      
        def current_article_tags
          article_tags_hash = {}
          if is_blog_article? && current_article_metadata.tags
            article_tags = current_article_metadata.tags.split(',').map{|t| t.strip}
            article_tags.each do |tag_title|
              article_tags_hash[tag_title] = self.class.blog_taglink.gsub(/(:\w+)/, tag_title.parameterize)
            end
          end
          article_tags_hash
        end
      
        def blog_tags
          data.blog.tags
        end
      
        def current_tag_data
          data.blog.tags[request.path]
        end
      
        def current_tag_articles
          data.blog.articles.map do |article|
            article if current_tag_data.pages.has_value?(article.url)
          end.compact
        end
      
        def current_tag_title
          current_tag_data[:title]
        end
      end
    end
  end
end
