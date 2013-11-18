module Middleman
  module Blog
    module Helpers
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
