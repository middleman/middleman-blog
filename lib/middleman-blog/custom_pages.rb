require 'middleman-blog/uri_templates'

module Middleman
  module Blog

    # This adds new summary pages for arbitrarily defined blog article properties
    class CustomPages
      include UriTemplates

      attr_reader :property

      def initialize(property, app, controller, options)
        @property = property
        @sitemap = app.sitemap
        @blog_controller = controller
        @blog_data = controller.data
        @link_template = uri_template options[:link]
        @page_template = options[:template]
      end

      # Return a path to the page for this property value.
      #
      # @param [String] value
      def link(value)
        apply_uri_template @link_template, property => safe_parameterize(value)
      end

      def manipulate_resource_list(resources)
        articles_by_property = @blog_data.articles.
          select {|a| a.data[property] }.
          group_by {|a| a.data[property] }
        resources + articles_by_property.map do |property_value, articles|
          build_resource(link(property_value), property_value, articles)
        end
      end

      private

      def build_resource(path, value, articles)
        articles = articles.sort_by(&:date).reverse
        Sitemap::ProxyResource.new(@sitemap, path, @page_template).tap do |p|
          p.add_metadata locals: {
            "page_type"       => property.to_s,
            property          => value,
            "articles"        => articles,
            "blog_controller" => @blog_controller
          }
        end
      end
    end
  end
end