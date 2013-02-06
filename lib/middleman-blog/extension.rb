module Middleman
  module Blog
    class Options
      KEYS = [
              :prefix,
              :permalink,
              :sources,
              :taglink,
              :layout,
              :summary_separator,
              :summary_length,
              :summary_generator,
              :year_link,
              :month_link,
              :day_link,
              :default_extension,
              :calendar_template,
              :year_template,
              :month_template,
              :day_template,
              :tag_template,
              :paginate,
              :per_page,
              :page_link,
              :publish_future_dated
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
        require 'active_support/core_ext/time/zones'

        app.set :time_zone, 'UTC'

        app.send :include, Helpers
        
        options = Options.new(options_hash)
        yield options if block_given?
        
        options.permalink            ||= "/:year/:month/:day/:title.html"
        options.sources              ||= ":year-:month-:day-:title.html"
        options.taglink              ||= "tags/:tag.html"
        options.layout               ||= "layout"
        options.summary_separator    ||= /(READMORE)/
        options.summary_length       ||= 250
        options.year_link            ||= "/:year.html"
        options.month_link           ||= "/:year/:month.html"
        options.day_link             ||= "/:year/:month/:day.html"
        options.default_extension    ||= ".markdown"
        options.paginate             ||= false
        options.per_page             ||= 10
        options.page_link            ||= "page/:num"
        options.publish_future_dated ||= false

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

        # If "prefix" option is specified, all other paths are relative to it.
        if options.prefix
          options.prefix = "/#{options.prefix}" unless options.prefix.start_with? '/'
          options.permalink = File.join(options.prefix, options.permalink)
          options.sources = File.join(options.prefix, options.sources)
          options.taglink = File.join(options.prefix, options.taglink)
          options.year_link = File.join(options.prefix, options.year_link)
          options.month_link = File.join(options.prefix, options.month_link)
          options.day_link = File.join(options.prefix, options.day_link)
        end

        app.after_configuration do
          # Make sure ActiveSupport's TimeZone stuff has something to work with,
          # allowing people to set their desired time zone via Time.zone or
          # set :time_zone
          time_zone = Time.zone if Time.zone
          zone_default = Time.find_zone!(time_zone || 'UTC')
          unless zone_default
            raise 'Value assigned to time_zone not recognized.'
          end
          Time.zone_default = zone_default

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

          if options.paginate
            require 'middleman-blog/paginator'
            sitemap.register_resource_list_manipulator(
                                                       :blog_paginate,
                                                       Paginator.new(self),
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
        blog.article(current_resource.path)
      end

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def tag_path(tag)
        sitemap.find_resource_by_path(TagPages.link(self, tag)).try(:url)
      end

      # Get a path to the given year-based calendar page, based on the :year_link setting.
      # @param [Number] year
      # @return [String]
      def blog_year_path(year)
        sitemap.find_resource_by_path(CalendarPages.link(self, year)).try(:url)
      end

      # Get a path to the given month-based calendar page, based on the :month_link setting.
      # @param [Number] year        
      # @param [Number] month
      # @return [String]
      def blog_month_path(year, month)
        sitemap.find_resource_by_path(CalendarPages.link(self, year, month)).try(:url)
      end

      # Get a path to the given day-based calendar page, based on the :day_link setting.
      # @param [Number] year        
      # @param [Number] month
      # @param [Number] day
      # @return [String]
      def blog_day_path(year, month, day)
        sitemap.find_resource_by_path(CalendarPages.link(self, year, month, day)).try(:url)
      end


      # Pagination Helpers
      # These are used by the template if pagination is off, to allow a single template to work
      # in both modes. They get overridden by the local variables if the paginator is active.

      # Returns true if pagination is turned on for this template; false otherwise.
      # @return [Boolean]
      def paginate; false; end

      # Returns the list of articles to display on this page.
      # @return [Array<Middleman::Sitemap::Resource>]
      def page_articles
        limit = (current_resource.metadata[:page]["per_page"] || 0) - 1

        # "articles" local variable is populated by Calendar and Tag page generators
        # If it's not set then use the complete list of articles
        (current_resource.metadata[:locals]["articles"] || blog.articles)[0..limit]
      end
    end
  end
end
