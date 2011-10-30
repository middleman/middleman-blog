module Middleman
  module Features
    module Blog
      class << self
        def registered(app)
          # Include helpers
          app.helpers Middleman::Features::Blog::Helpers

          app.after_configuration do
            if !app.settings.respond_to? :blog_permalink
              app.set :blog_permalink, ":year/:month/:day/:title.html"
            end

            if !app.settings.respond_to? :blog_taglink
              app.set :blog_taglink, "tags/:tag.html"
            end

            if !app.settings.respond_to? :blog_layout
              app.set :blog_layout, "layout"
            end

            if !app.settings.respond_to? :blog_summary_separator
              app.set :blog_summary_separator, /READMORE/
            end

            if !app.settings.respond_to? :blog_summary_length
              app.set :blog_summary_length, 250
            end

            if !app.settings.respond_to? :blog_layout_engine
              app.set :blog_layout_engine, "erb"
            end

            if !app.settings.respond_to? :blog_index_template
              app.set :blog_index_template, "index_template"
            end

            if !app.settings.respond_to? :blog_article_template
              app.set :blog_article_template, "article_template"
            end

            if !app.build?
              $stderr.puts "== Blog: #{app.settings.blog_permalink}"
            end
            
            app.get("/#{app.blog_permalink}") do
              process_request({
                :layout        => app.blog_layout,
                :layout_engine => app.blog_layout_engine
              })

              current_body = body
              current_body = current_body.first if current_body.class == Array
              # No need for separator on permalink page
              body current_body.gsub(app.blog_summary_separator, "")
            end
          end
          
          app.before_processing do
            articles_glob = File.join(app.views, app.settings.blog_permalink.gsub(/(:\w+)/, "*") + ".*")

            articles = Dir[articles_glob].map do |article|
              template_content = File.read(article)
              data, content = app.parse_front_matter(template_content)
              data["date"] = Date.parse("#{data['date']}")

              data["raw"] = content
              data["url"] = article.gsub(app.views, "").split(".html").first + ".html"

              all_content = Tilt.new(article).render
              data["body"] = all_content.gsub(app.settings.blog_summary_separator, "")

              sum = if data["raw"] =~ app.settings.blog_summary_separator
                data["raw"].split(app.settings.blog_summary_separator).first
              else
                data["raw"].match(/(.{1,#{app.settings.blog_summary_length}}.*?)(\n|\Z)/m).to_s
              end

              engine = app.settings.markdown_engine
              if engine.is_a? Symbol
                engine = app.tilt_template_from_symbol(engine)
              end
              
              engine = engine.new { sum }
              data["summary"] = engine.render
              data
            end.sort { |a, b| b["date"] <=> a["date"] }

            tags = {}
            articles.each do |article|
              article["tags"] ||= ""
              if !article["tags"].empty?
                tags_array = article["tags"].split(',').map{|t| t.strip}
                tags_array.each do |tag_title|
                  tag_key = tag_title.parameterize
                  tag_path = blog_taglink.gsub(/(:\w+)/, tag_key)
                  (tags[tag_path] ||= {})["title"] = tag_title
                  tags[tag_path]["ident"] = tag_key
                  (tags[tag_path]["pages"] ||= {})[article["title"]] = article["url"]
                end
              end
            end

            app.data_content("blog", { :articles => articles, :tags => tags })
            true
          end
        end
        alias :included :registered
      end

      module Helpers
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
