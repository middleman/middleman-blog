module Middleman
  module Blog

    # This adds new summary pages for arbitrarily defined blog article properties
    class CustomPages

      attr_reader :property

      def initialize(property, app, controller)
        @property = property
        @sitemap = app.sitemap
        @blog_controller = controller
        @blog_options = controller.options
        @blog_data = controller.data
      end

      # Return a path to the given property / value pair
      #
      # @param [Hash] blog_options
      # @param [String|Symbol] property Frontmatter property used to collect on
      # @param [String| value Frontmatter value for the given article for the given property
      def link(value)
        link_template = @blog_options.custom_collections[property][:link]
        ::Middleman::Util.normalize_path link_template.sub(":#{property}", value.parameterize)
      end

      def manipulate_resource_list(resources)
        articles_by_property = @blog_data.articles.group_by { |a| a.data[property] }
        resources + articles_by_property.map do |property_value, articles|
          build_resource(link(property_value), property_value, articles)
        end
      end

      private

      def build_resource(path, value, articles)
        articles = articles.sort_by(&:date).reverse
        Sitemap::Resource.new(@sitemap, path).tap do |p|
          p.proxy_to(@blog_options.custom_collections[property][:template])
          p.add_metadata :locals => {
            "page_type"       => property,
            property          => value,
            "articles"        => articles,
            "blog_controller" => @blog_controller
          }
        end
      end
    end
  end
end
