module Middleman
  module Blog

    # A sitemap plugin that adds tag pages to the sitemap
    # based on the tags of blog articles.
    class TagPages
      class << self
        # Get a path to the given tag, based on the :taglink setting.
        # @param [Hash] blog_options
        # @param [String] tag
        # @return [String]
        def link(blog_options, tag)
          ::Middleman::Util.normalize_path(blog_options.taglink.sub(':tag', tag.parameterize))
        end
      end

      def initialize(app, controller=nil)
        @app = app
        @blog_controller = controller
      end

      def blog_data
        if @blog_controller
          @blog_controller.data
        else
          @app.blog
        end
      end

      def blog_options
        if @blog_controller
          @blog_controller.options
        else
          @app.blog.options
        end
      end
      
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources + self.blog_data.tags.map do |tag, articles|
          path = TagPages.link(self.blog_options, tag)
          
          p = ::Middleman::Sitemap::Resource.new(
            @app.sitemap,
            path
          )
          p.proxy_to(self.blog_options.tag_template)

          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata :locals => {
            'page_type' => 'tag',
            'tagname' => tag,
            'articles' => articles,
            'blog_controller' => @blog_controller
          }
          # Add metadata in instance variables for backwards compatibility
          p.add_metadata do
            @tag = tag
            @articles = articles
          end

          p
        end
      end
    end
  end
end
