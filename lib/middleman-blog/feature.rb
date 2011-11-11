require "date"

module Middleman
  module Features
    module Blog
      class << self
        def registered(app)
          app.extend ClassMethods
          
          app.file_changed do |file|
            blog.touch_file(file)
          end

          app.file_deleted do |file|
            blog.remove_file(file)
          end
          
          # Include helpers
          app.helpers Helpers

          app.after_configuration do
            if !settings.respond_to? :blog_permalink
              set :blog_permalink, ":year/:month/:day/:title.html"
            end

            if !settings.respond_to? :blog_taglink
              set :blog_taglink, "tags/:tag.html"
            end

            if !settings.respond_to? :blog_layout
              set :blog_layout, "layout"
            end

            if !settings.respond_to? :blog_summary_separator
              set :blog_summary_separator, /READMORE/
            end

            if !settings.respond_to? :blog_summary_length
              set :blog_summary_length, 250
            end

            if !settings.respond_to? :blog_layout_engine
              set :blog_layout_engine, "erb"
            end

            if !settings.respond_to? :blog_index_template
              set :blog_index_template, "index_template"
            end

            if !settings.respond_to? :blog_article_template
              set :blog_article_template, "article_template"
            end

            if !build?
              $stderr.puts "== Blog: #{settings.blog_permalink}"
            end
            
            app.get("/#{settings.blog_permalink}") do
              process_request({
                :layout        => settings.blog_layout,
                :layout_engine => settings.blog_layout_engine
              })

              current_body = body
              current_body = current_body.first if current_body.class == Array
              # No need for separator on permalink page
              body current_body.gsub(settings.blog_summary_separator, "")
            end
            
            app.blog
          end
        end
        alias :included :registered
      end
      
      module ClassMethods
        def blog
          @blog ||= BlogData.new(self)
        end
      end

      class BlogData
        def initialize(app)
          @app = app
          @articles = {}
          
          matcher = @app.settings.blog_permalink
          matcher.sub!(":year",  "(\\d{4})")
          matcher.sub!(":month", "(\\d{2})")
          matcher.sub!(":day",   "(\\d{2})")
          matcher.sub!(":title", "(.*)")
          @match_reg = %r{#{matcher}}
          
          article_paths = []
          @app.sitemap.each do |k, v|
            next unless v === true
            article_paths << k unless @match_reg.match(k).nil?
          end
          
          article_paths.each do |path|
            next unless @app.sitemap.source_map.has_key?(path)
            file = @app.sitemap.source_map[path]
            @articles[file] = BlogArticle.new(@app, file)
          end
          
          self.update_data
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
                tag_path = @app.settings.blog_taglink.gsub(/(:\w+)/, tag_key)
                (tags[tag_path] ||= {})["title"] = tag_title
                tags[tag_path]["ident"] = tag_key
                (tags[tag_path]["pages"] ||= {})[article.title] = article.url
              end
              
              tags
            end
          end
        end
        
        def touch_file(file)
          @articles[file] = BlogArticle.new(@app, file)
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
            :articles => self.sorted_articles.map { |a| a.to_h }, 
            :tags     => self.tags
          })
        end
      end
      
      class BlogArticle
        attr_accessor :date, :title, :raw, :url, :body, :summary, :frontmatter
        
        def initialize(app, file)
          template_content = File.read(file)
          
          source = File.expand_path(app.views, app.root)
          path   = file.sub(source, "")
          data, content = app.frontmatter.data(path)
          
          if data["date"] && data["date"].is_a?(String)
            if data["date"].match(/\d{4}\/\d{2}\/\d{2}/)
              self.date = Date.strptime(data["date"], '%Y/%m/%d')
            elsif data["date"].match(/\d{2}\/\d{2}\/\d{4}/)
              self.date = Date.strptime(data["date"], '%d/%m/%Y')
            end
          end
        
          self.frontmatter = data
          self.title = data["title"]
          self.raw = content
          self.url = app.sitemap.source_map.index(file)
      
          all_content = ::Tilt.new(file).render
          self.body = all_content.sub(app.settings.blog_summary_separator, "")

          sum = if self.raw =~ app.settings.blog_summary_separator
            self.raw.split(app.settings.blog_summary_separator).first
          else
            self.raw.match(/(.{1,#{app.settings.blog_summary_length}}.*?)(\n|\Z)/m).to_s
          end
      
          engine = app.settings.markdown_engine
          if engine.is_a? Symbol
            engine = app.markdown_tilt_template_from_symbol(engine)
          end
          
          engine = engine.new { sum }
          self.summary = engine.render
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
      
      module Helpers
        def blog
          self.class.blog
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
