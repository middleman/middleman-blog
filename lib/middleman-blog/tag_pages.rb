module Middleman
  module Blog

    # A sitemap plugin that adds tag pages to the sitemap
    # based on the tags of blog articles.
    class TagPages
      def initialize(app)
        @app = app
      end
      
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        resources + @app.blog.tags.map do |tag, articles|
          path = Middleman::Util.normalize_path(@app.tag_path(tag))
          
          p = ::Middleman::Sitemap::Resource.new(
            @app.sitemap,
            path
          )
          p.proxy_to(@app.blog_tag_template)

          set_locals = Proc.new do
            @tag = tag
            @articles = articles
          end

          # TODO: how to keep from adding duplicates here?
          # How could we better set locals?
          @app.sitemap.provides_metadata_for_path path, :blog_tags do |path|
            { :blocks => [ set_locals ] }
          end

          p
        end
      end
    end
  end
end
