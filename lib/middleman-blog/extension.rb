module Middleman
  module Blog
    class Options
      KEYS = [
        :permalink,
        :sources,
        :taglink,
        :layout,
        :summary_separator,
        :summary_length,
        :year_link,
        :month_link,
        :day_link,
        :default_extension,
        :calendar_template,
        :year_template,
        :month_template,
        :day_template,
        :tag_template
      ]
      
      KEYS.each do |name|
        attr_accessor name
      end
      
      def initialize(options={})
        options.each do |k,v|
          self.send(:"#{k}=", v)
        end
      end
    end
    
    class << self
      def registered(app, options_hash={}, &block)
        require 'middleman-blog/blog_data'
        require 'middleman-blog/blog_article'
        
        app.send :include, Helpers
        
        options = Options.new(options_hash)
        yield options if block_given?
        
        options.permalink         ||= "/:year/:month/:day/:title.html"
        options.sources           ||= ":year-:month-:day-:title.html"
        options.taglink           ||= "tags/:tag.html"
        options.layout            ||= "layout"
        options.summary_separator ||= /(READMORE)/
        options.summary_length    ||= 250
        options.year_link         ||= "/:year.html"
        options.month_link        ||= "/:year/:month.html"
        options.day_link          ||= "/:year/:month/:day.html"
        options.default_extension ||= ".markdown"

        # optional: :tag_template
        # optional: :year_template
        # optional: :month_template
        # optional: :day_template
        # Allow one setting to set all the calendar templates
        if options.calendar_template
          options.year_template  ||= options.calendar_template
          options.month_template ||= options.calendar_template
          options.day_template   ||= options.calendar_template
        end

        app.after_configuration do
          # Initialize blog with options
          blog(options)
          
          sitemap.register_resource_list_manipulator(
            :blog_articles,
            blog,
            false
          )

          if options.tag_template
            ignore options.tag_template

            require 'middleman-blog/tag_pages'
            sitemap.register_resource_list_manipulator(
              :blog_tags,
              TagPages.new(self),
              false
            )
          end

          if options.year_template || 
             options.month_template || 
             options.day_template

            require 'middleman-blog/calendar_pages'
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
      def blog(options=nil)
        @_blog ||= BlogData.new(self, options)
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

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def tag_path(tag)
        blog.taglink.sub(':tag', tag.parameterize)
      end

      # Get a path to the given year-based calendar page, based on the :year_link setting.
      # @param [Number] year
      # @return [String]
      def blog_year_path(year)
        blog.year_link.sub(':year', year.to_s)
      end

      # Get a path to the given month-based calendar page, based on the :month_link setting.
      # @param [Number] year        
      # @param [Number] month
      # @return [String]
      def blog_month_path(year, month)
        blog.month_link.sub(':year', year.to_s).
          sub(':month', month.to_s.rjust(2,'0'))
      end

      # Get a path to the given day-based calendar page, based on the :day_link setting.
      # @param [Number] year        
      # @param [Number] month
      # @param [Number] day
      # @return [String]
      def blog_day_path(year, month, day)
        blog.day_link.sub(':year', year.to_s).
          sub(':month', month.to_s.rjust(2,'0')).
          sub(':day', day.to_s.rjust(2,'0'))
      end
    end
  end
end
