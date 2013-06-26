module Middleman
  class BlogExtension < Extension
    self.supports_multiple_instances = true

    option :name, nil, 'Unique ID for telling multiple blogs apart'
    option :prefix, nil, 'Prefix to mount the blog at'
    option :permalink, "/:year/:month/:day/:title.html", 'HTTP path to host articles at'
    option :sources, ":year-:month-:day-:title.html", 'How to extract metadata from on-disk files'
    option :taglink, "tags/:tag.html", 'HTTP path to host tag pages at'
    option :layout, "layout", 'Article-specific layout'
    option :summary_separator, /(READMORE)/, 'How to split article summaries around a delimeter'
    option :summary_length, 250, 'Length of words in automatic summaries'
    option :summary_generator, nil, 'Block to definte how summaries are extracted'
    option :year_link, "/:year.html", 'HTTP path for yearly archives'
    option :month_link, "/:year/:month.html", 'HTTP path for monthly archives'
    option :day_link, "/:year/:month/:day.html", 'HTTP path for daily archives'
    option :default_extension, ".markdown", 'Default article extension'
    option :calendar_template, nil, 'Template for calendar pages'
    option :year_template, nil, 'Template for yearly archive pages'
    option :month_template, nil, 'Template for monthyl archive pages'
    option :day_template, nil, 'Template for daily archive pages'
    option :tag_template, nil, 'Template for tag archive pages'
    option :paginate, false, 'Whether to paginate pages'
    option :per_page, 10, 'Articles per page when paginating'
    option :page_link, "page/:num", 'HTTP path for paging'
    option :publish_future_dated, false, 'Whether to pubish articles dated in the future'

    attr_accessor :data, :uid

    def initialize(app, options_hash={}, &block)
      super

      @uid = options.name

      require 'middleman-blog/blog_data'
      require 'middleman-blog/blog_article'
      require 'active_support/core_ext/time/zones'

      # app.set :time_zone, 'UTC'

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
    end

    def after_configuration
      @uid ||= "blog#{@app.blog_instances.keys.length}"

      @app.ignore(options.calendar_template) if options.calendar_template
      @app.ignore(options.year_template) if options.year_template
      @app.ignore(options.month_template) if options.month_template
      @app.ignore(options.day_template) if options.day_template

      @app.blog_instances[@uid.to_sym] = self

      # Make sure ActiveSupport's TimeZone stuff has something to work with,
      # allowing people to set their desired time zone via Time.zone or
      # set :time_zone
      Time.zone = app.config[:time_zone] if app.config[:time_zone]
      time_zone = Time.zone if Time.zone
      zone_default = Time.find_zone!(time_zone || 'UTC')
      unless zone_default
        raise 'Value assigned to time_zone not recognized.'
      end
      Time.zone_default = zone_default

      # Initialize blog with options

      @data = ::Middleman::Blog::BlogData.new(@app, options, self)

      @app.sitemap.register_resource_list_manipulator(
        :"blog_#{uid}_articles",
        @data,
        false
      )

      if options.tag_template
        @app.ignore options.tag_template

        require 'middleman-blog/tag_pages'
        @app.sitemap.register_resource_list_manipulator(
          :"blog_#{uid}_tags",
          ::Middleman::Blog::TagPages.new(@app, self),
          false
        )
      end

      if options.year_template || options.month_template || options.day_template
        require 'middleman-blog/calendar_pages'
        @app.sitemap.register_resource_list_manipulator(
          :"blog_#{uid}_calendar",
          ::Middleman::Blog::CalendarPages.new(@app, self),
          false
        )
      end

      if options.paginate
        require 'middleman-blog/paginator'
        @app.sitemap.register_resource_list_manipulator(
          :"blog_#{uid}_paginate",
          ::Middleman::Blog::Paginator.new(@app, self),
          false
        )
      end
    end

    # Helpers for use within templates and layouts.
    helpers do
      def blog_instances
        @blog_instances ||= {}
      end

      def blog_controller(key=nil)
        key ||= blog_instances.keys.first
        blog_instances[key.to_sym]
      end

      def blog(key=nil)
        blog_controller(key).data
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
        blog_instances.each do |key, blog|
          found = blog.data.article(current_resource.path)
          return found if found
        end

        nil
      end

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def tag_path(tag, key=nil)
        sitemap.find_resource_by_path(::Middleman::Blog::TagPages.link(blog_controller(key).options, tag)).try(:url)
      end

      # Get a path to the given year-based calendar page, based on the :year_link setting.
      # @param [Number] year
      # @return [String]
      def blog_year_path(year, key=nil)
        sitemap.find_resource_by_path(::Middleman::Blog::CalendarPages.link(blog_controller(key).options, year)).try(:url)
      end

      # Get a path to the given month-based calendar page, based on the :month_link setting.
      # @param [Number] year
      # @param [Number] month
      # @return [String]
      def blog_month_path(year, month, key=nil)
        sitemap.find_resource_by_path(::Middleman::Blog::CalendarPages.link(blog_controller(key).options, year, month)).try(:url)
      end

      # Get a path to the given day-based calendar page, based on the :day_link setting.
      # @param [Number] year
      # @param [Number] month
      # @param [Number] day
      # @return [String]
      def blog_day_path(year, month, day, key=nil)
        sitemap.find_resource_by_path(::Middleman::Blog::CalendarPages.link(blog_controller(key).options, year, month, day)).try(:url)
      end

      # Pagination Helpers
      # These are used by the template if pagination is off, to allow a single template to work
      # in both modes. They get overridden by the local variables if the paginator is active.

      # Returns true if pagination is turned on for this template; false otherwise.
      # @return [Boolean]
      def paginate; false; end

      # Returns the list of articles to display on this page.
      # @return [Array<Middleman::Sitemap::Resource>]
      def page_articles(key=nil)
        limit = (current_resource.metadata[:page]["per_page"] || 0) - 1

        # "articles" local variable is populated by Calendar and Tag page generators
        # If it's not set then use the complete list of articles
        d = (current_resource.metadata[:locals]["articles"] || blog(key).articles)[0..limit]
      end
    end
  end
end
