require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap resource manipulator that adds a category page to the sitemap
    # for each tag in the associated blog
    class CategoryPages
      include UriTemplates

      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_controller = blog_controller
        @category_link_template = uri_template blog_controller.options.categorylink
        @category_template = blog_controller.options.category_template
        @blog_data = blog_controller.data
      end

      # Get a path to the given category, based on the :categorylink setting.
      # @param [String] category
      # @return [String]
      def link(category)
        apply_uri_template @category_link_template, category: safe_parameterize(category)
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources + @blog_data.categories.map do |category, articles|
          category_page_resource(category, articles)
        end
      end

      private

      def category_page_resource(category, articles)
        Sitemap::Resource.new(@sitemap, link(category)).tap do |p|
          p.proxy_to(@category_template)

          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'category',
            'categoryname' => category,
            'articles' => articles,
            'blog_controller' => @blog_controller
          }
        end
      end
    end
  end
end
