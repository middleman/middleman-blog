module Middleman
  class BlogExtension < Extension
    self.supports_multiple_instances = true

    option :name, nil, 'Unique ID for telling multiple blogs apart'
    option :prefix, nil, 'Prefix to mount the blog at (modifies permalink, sources, taglink, year_link, month_link, day_link to start with the prefix)'
    option :permalink, "/:year/:month/:day/:title.html", 'Path articles are generated at. Tokens can be omitted or duplicated, and you can use tokens defined in article frontmatter.'
    option :sources, ":year-:month-:day-:title.html", 'Pattern for matching source blog articles (no template extensions)'
    option :taglink, "tags/:tag.html", 'Path tag pages are generated at.'
    option :layout, "layout", 'Article-specific layout'
    option :summary_separator, /(READMORE)/, 'Regex or string that delimits the article summary from the rest of the article.'
    option :summary_length, 250, 'Truncate summary to be <= this number of characters. Set to -1 to disable summary truncation.'
    option :summary_generator, nil, 'A block that defines how summaries are extracted. It will be passed the rendered article content, max summary length, and ellipsis string as arguments.'
    option :year_link, "/:year.html", 'Path yearly archive pages are generated at.'
    option :month_link, "/:year/:month.html", 'Path monthly archive pages are generated at.'
    option :day_link, "/:year/:month/:day.html", 'Path daily archive pages are generated at.'
    option :default_extension, ".markdown", 'Default template extension for articles (used by "middleman article")'
    option :calendar_template, nil, 'Template path (no template extension) for calendar pages (year/month/day archives).'
    option :year_template, nil, 'Template path (no template extension) for yearly archive pages. Defaults to the :calendar_template.'
    option :month_template, nil, 'Template path (no template extension) for monthly archive pages. Defaults to the :calendar_template.'
    option :day_template, nil, 'Template path (no template extension) for daily archive pages. Defaults to the :calendar_template.'
    option :tag_template, nil, 'Template path (no template extension) for tag archive pages.'
    option :paginate, false, 'Whether to paginate lists of articles'
    option :per_page, 10, 'Number of articles per page when paginating'
    option :page_link, "page/:num", 'Path to append for additional pages when paginating'
    option :publish_future_dated, false, 'Whether articles with a date in the future should be considered published'
    option :custom_collections, {}, 'Hash of custom frontmatter properties to collect articles on and their options (link, template)'
    option :preserve_locale, false, 'Use the global Middleman I18n.locale instead of the lang in the article\'s frontmatter'

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

        options.custom_collections.each do |key, opts|
          opts[:link] = File.join(options.prefix, opts[:link])
        end
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

      if options.custom_collections
        require 'middleman-blog/custom_pages'
        register_custom_pages
      end
    end

    # Register any custom page collections that may be set in the config
    #
    # A custom resource list manipulator will be generated for each key in the
    # custom collections hash.
    #
    # The following will collect posts on the "category" frontmatter property:
    #   ```
    #   activate :blog do |blog|
    #     blog.custom_collections = {
    #       category: {
    #         link: "/categories/:category.html",
    #         template: "/category.html"
    #       }
    #     }
    #   end
    #   ```
    #
    # Category pages in the example above will use the category.html as a template file
    # and it will be ignored when building.
    def register_custom_pages
      options.custom_collections.each do |property, options|
        @app.ignore options[:template]
        @app.sitemap.register_resource_list_manipulator(
          :"blog_#{uid}_#{property}",
          ::Middleman::Blog::CustomPages.new(property, @app, self),
          false
        )

        generate_custom_helper(property)
      end
    end

    # Generate helpers to access the path to a custom collection.
    #
    # For example, when using a custom property called "category" to collect articles on
    # the method **category_path** will be generated.
    #
    # @param [Symbol] custom_property Custom property which is being used to collect articles on
    def generate_custom_helper(custom_property)
      m = Module.new
      m.module_eval(%Q{
        def #{custom_property}_path(value, key = nil)
          sitemap.find_resource_by_path(::Middleman::Blog::CustomPages.link(blog_controller(key).options, :#{custom_property}, value)).try(:url)
        end
      })

      app.class.send(:include, m)
    end

    # Helpers for use within templates and layouts.
    helpers do
      def blog_instances
        @blog_instances ||= {}
      end

      def blog_controller(key=nil)
        if !key && current_resource
          key = current_resource.metadata[:page]["blog"]

          if !key && current_resource.respond_to?(:blog_controller) && current_resource.blog_controller
            return current_resource.blog_controller
          end
        end

        # In multiblog situations, force people to specify the blog
        if !key && blog_instances.size > 1
          raise "You must either specify the blog name in calling this method or in your page frontmatter (using the 'blog' key)"
        end

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
