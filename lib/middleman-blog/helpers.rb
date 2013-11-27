module Middleman
  module Blog
    # Blog-related helpers that are available to the Middleman application in +config.rb+ and in templates.
    module Helpers
      # All the blog instances known to this Middleman app, keyed by name. A new blog is added
      # every time the blog extension is activated. Name them by setting the +:name+
      # option when activating - otherwise they get an automatic name like 'blog0', 'blog1', etc.
      #
      # @return [Hash<Symbol,BlogExtension>] a hash of all blog instances by name
      def blog_instances
        @blog_instances ||= {}
      end

      # Retrieve a {BlogExtension} instance.
      # If +blog_name+ is provided, the instance with that name will be returned.
      # Otherwise, an attempt is made to find the appropriate blog controller
      # for the current resource. For articles this is always available, but
      # for other pages it may be necessary to name the blog in frontmatter
      # using the "blog" blog_name. If there is only one blog, this method will
      # always return that blog.
      #
      # @param [Symbol, String] blog_name Optional name of the blog to get a controller for.
      # @return [BlogExtension]
      def blog_controller(blog_name=nil)
        if !blog_name && current_resource
          blog_name = current_resource.metadata[:page]["blog"]

          if !blog_name
            blog_controller = current_resource.blog_controller if current_resource.respond_to?(:blog_controller)
            return blog_controller if blog_controller
          end
        end

        # In multiblog situations, force people to specify the blog
        if !blog_name && blog_instances.size > 1
          raise "You must either specify the blog name in calling this method or in your page frontmatter (using the 'blog' blog_name)"
        end

        blog_name ||= blog_instances.keys.first
        blog_instances[blog_name.to_sym]
      end

      # Get a {BlogData} instance for the given blog. Follows the
      # same rules as {#blog_controller}.
      #
      # @param [Symbol, String] blog_name Optional name of the blog to get data for.
      #   Blogs can be named as an option or will default to 'blog0', 'blog1', etc..
      # @return [BlogData]
      def blog(blog_name=nil)
        blog_controller(blog_name).data
      end

      # Determine whether the currently rendering template is a {BlogArticle}.
      # This can be useful in layouts and helpers.
      # @return [Boolean]
      def is_blog_article?
        !current_article.nil?
      end

      # Get a {BlogArticle} representing the current article.
      # @return [BlogArticle]
      def current_article
        article = current_resource
        if article && article.is_a?(BlogArticle)
          article
        else
          nil
        end
      end

      # Get a path to the given tag page, based on the +taglink+ blog setting.
      # @param [String] tag
      # @param [Symbol, String] blog_name Optional name of the blog to use.
      # @return [String]
      def tag_path(tag, blog_name=nil)
        build_url blog_controller(blog_name).tag_pages.link(tag)
      end

      # Get a path to the given year-based calendar page, based on the +year_link+ blog setting.
      # @param [Number] year
      # @param [Symbol, String] blog_name Optional name of the blog to use.
      # @return [String]
      def blog_year_path(year, blog_name=nil)
        build_url blog_controller(blog_name).calendar_pages.link(year)
      end

      # Get a path to the given month-based calendar page, based on the +month_link+ blog setting.
      # @param [Number] year
      # @param [Number] month
      # @param [Symbol, String] blog_name Optional name of the blog to use.
      # @return [String]
      def blog_month_path(year, month, blog_name=nil)
        build_url blog_controller(blog_name).calendar_pages.link(year, month)
      end

      # Get a path to the given day-based calendar page, based on the +day_link+ blog setting.
      # @param [Number] year
      # @param [Number] month
      # @param [Number] day
      # @param [Symbol, String] blog_name Optional name of the blog to use.
      # @return [String]
      def blog_day_path(year, month, day, blog_name=nil)
        build_url blog_controller(blog_name).calendar_pages.link(year, month, day)
      end

      # Whether or not pagination is enabled for this template. This can be used
      # to allow a single template to work in both paginating and non-paginating modes.
      # @return [Boolean]
      def paginate
        false
      end

      # Returns the list of articles to display on this particular page (when using pagination).
      # @param [Symbol, String] blog_name Optional name of the blog to use.
      # @return [Array<Middleman::Sitemap::Resource>]
      def page_articles(blog_name=nil)
        meta = current_resource.metadata
        limit = meta[:page]["per_page"]

        # "articles" local variable is populated by Calendar and Tag page generators
        # If it's not set then use the complete list of articles
        articles = meta[:locals]["articles"] || blog(blog_name).articles

        limit ? articles.first(limit) : articles
      end

      # Generate helpers to access the path to a custom collection.
      #
      # For example, when using a custom property called "category" to collect articles on
      # the method **category_path** will be generated.
      #
      # @param [Symbol] property Custom property which is being used to collect articles on
      # @private
      def self.generate_custom_helper(property)
        define_method :"#{property}_path" do |value, blog_name=nil|
          custom_pages = blog_controller(blog_name).custom_pages

          if !custom_pages.key?(property)
            raise "This blog does not know about the custom property #{property.inspect}"
          end
          build_url custom_pages[property].link(value)
        end
      end

      private

      def build_url(path)
        sitemap.find_resource_by_path(path).try(:url)
      end
    end
  end
end
