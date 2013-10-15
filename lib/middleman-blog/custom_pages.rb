module Middleman
  module Blog

    class CustomPages

      class << self

        # Return a path to the given property / value pair
        #
        # @param [Hash] blog_options
        # @param [String|Symbol] property Frontmatter property used to collect on
        # @param [String| value Frontmatter value for the given article for the given property
        def link(blog_options, property, value)
          link_template = blog_options.custom_collections[property][:link]
          ::Middleman::Util.normalize_path(link_template.sub(":#{property}", value.parameterize))
        end

      end

      attr_reader :property, :app, :blog_controller

      def initialize(property, app, controller = nil)
        @property        = property
        @app             = app
        @blog_controller = controller
      end

      def blog_data
        if blog_controller
          blog_controller.data
        else
          app.blog
        end
      end

      def blog_options
        if blog_controller
          blog_controller.options
        else
          app.blog.options
        end
      end

      def articles
        blog_data.articles
      end

      def manipulate_resource_list(resources)
        new_resources = []

        articles.group_by { |a| a.data[property] }.each do |property_value, property_articles|
          path = CustomPages.link(blog_options, property, property_value)
          new_resources << build_resource(path, property_value, property_articles)
        end

        resources + new_resources
      end

      def build_resource(path, value, property_articles)
        p = ::Middleman::Sitemap::Resource.new(app.sitemap, path)
        p.proxy_to(template_for_page)
        p.add_metadata :locals => {
          "page_type"       => property,
          "#{property}"     => value,
          "articles"        => property_articles,
          "blog_controller" => blog_controller
        }

        prop_name = property
        p.add_metadata do
          instance_variable_set("@#{prop_name}", value)
          @articles = property_articles
        end

        p
      end

      def template_for_page
        blog_options.custom_collections[property][:template]
      end
      
    end

  end
end
