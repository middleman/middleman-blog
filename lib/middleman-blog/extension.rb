require 'middleman-blog/blog_data'
require 'middleman-blog/blog_article'

module Middleman
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
        
        app.send :include, Helpers

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

    # Helpers for use within templates and layouts.
    module Helpers
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
