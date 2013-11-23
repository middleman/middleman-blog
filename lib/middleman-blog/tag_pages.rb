module Middleman
  module Blog
    # A sitemap resource manipulator that adds a tag page to the sitemap
    # for each tag in the associated blog
    class TagPages
      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_options = blog_controller.options
        @blog_data = blog_controller.data
      end

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def link(tag)
        # parameterize only tag ASCII tag
        tag = tag.parameterize if tag.split('').all? { |c| c.bytes.count == 1 }
        @blog_options.taglink.sub(':tag', tag)
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources + @blog_data.tags.map do |tag, articles|
          tag_page_resource(tag, articles)
        end
      end

      private

      def tag_page_resource(tag, articles)
          Sitemap::Resource.new(@sitemap, link(tag)).tap do |p|
            p.proxy_to(@blog_options.tag_template)

            # Add metadata in local variables so it's accessible to
            # later extensions
            p.add_metadata :locals => {
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
