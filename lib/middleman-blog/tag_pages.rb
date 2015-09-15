require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap resource manipulator that adds a tag page to the sitemap
    # for each tag in the associated blog
    class TagPages
      include UriTemplates

      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_controller = blog_controller
        @tag_link_template = uri_template blog_controller.options.taglink
        @tag_template = blog_controller.options.tag_template
        @blog_data = blog_controller.data

        @generate_tag_pages = blog_controller.options.generate_tag_pages
      end

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def link(tag)
        apply_uri_template @tag_link_template, tag: safe_parameterize(tag)
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        return resources unless @generate_tag_pages

        resources + @blog_data.tags.map do |tag, articles|
          tag_page_resource(tag, articles)
        end
      end

      private

      def tag_page_resource(tag, articles)
        Sitemap::ProxyResource.new(@sitemap, link(tag), @tag_template).tap do |p|
          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'tag',
            'tagname' => tag,
            'articles' => articles,
            'blog_controller' => @blog_controller
          }
        end
      end
    end
  end
end
