require 'middleman-blog/blog_data'
require 'middleman-blog/blog_article'
require 'middleman-blog/calendar_pages'
require 'middleman-blog/tag_pages'

module Middleman
  module Blog
    class << self
      def registered(app)
        app.set :blog_permalink, "/:year/:month/:day/:title.html"
        app.set :blog_sources, ":year-:month-:day-:title.html"
        app.set :blog_taglink, "tags/:tag.html"
        app.set :blog_layout, "layout"
        app.set :blog_summary_separator, /(READMORE)/
        app.set :blog_summary_length, 250
        app.set :blog_year_link, "/:year.html"
        app.set :blog_month_link, "/:year/:month.html"
        app.set :blog_day_link, "/:year/:month/:day.html"
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

          sitemap.register_resource_list_manipulator(
            :blog_articles,
            blog,
            false
          )

          if defined? blog_tag_template
            ignore blog_tag_template

            sitemap.register_resource_list_manipulator(
              :blog_tags,
              TagPages.new(self),
              false
            )
          end

          if defined? blog_year_template || 
             defined? blog_month_template || 
             defined? blog_day_template

            sitemap.register_resource_list_manipulator(
              :blog_calendar,
              CalendarPages.new(self),
              false
            )
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

      # Get a {Resource} with mixed in {BlogArticle} methods representing the current article.
      # @return [Middleman::Sitemap::Resource]
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
