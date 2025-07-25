# frozen_string_literal: true

require 'middleman-core'
require 'middleman-core/sitemap/resource'
require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    ##
    # A sitemap resource manipulator that adds alias/redirect pages to the sitemap
    # for each blog article based on the configured alias patterns
    ##
    class AliasPages
      include UriTemplates

      ##
      # Initialise Alias pages
      #
      # @param  app             [Object] Middleman app
      # @param  blog_controller [Object] Blog controller
      ##
      def initialize(app, blog_controller)
        @sitemap         = app.sitemap
        @blog_controller = blog_controller
        @blog_data       = blog_controller.data
        @alias_patterns  = blog_controller.options.aliases || []
        @alias_templates = @alias_patterns.map { |pattern| uri_template(pattern) }
      end

      ##
      # Update the main sitemap resource list
      #
      # @param  resources [Array] Existing resources
      # @return           [Array] Resources with alias pages added
      ##
      def manipulate_resource_list(resources)
        return resources if @alias_patterns.empty?

        alias_resources = []

        @blog_data.articles.each do |article|
          @alias_templates.each do |template|
            alias_path = generate_alias_path(template, article)
            next if alias_path == article.destination_path # Don't create alias to itself

            alias_resources << alias_page_resource(alias_path, article)
          end
        end

        resources + alias_resources
      end

      private

      ##
      # Generate an alias path for an article using the given template
      #
      # @param  template [Addressable::Template] URI template for the alias
      # @param  article  [BlogArticle] The blog article
      # @return [String] The generated alias path
      ##
      def generate_alias_path(template, article)
        # Get the same parameters used for the main permalink
        params = permalink_options(article)
        apply_uri_template(template, params)
      end

      ##
      # Generate permalink options for an article (same as BlogData uses)
      #
      # @param  article [BlogArticle] The blog article
      # @return [Hash] Parameters for URL generation
      ##
      def permalink_options(article)
        # Get variables from all alias templates
        all_variables = @alias_templates.flat_map(&:variables).uniq
        
        # Allow any frontmatter data to be substituted into the alias URL
        page_data = article.metadata[:page] || {}
        params = page_data.slice(*all_variables.map(&:to_sym))

        params.each do |k, v|
          params[k] = safe_parameterize(v)
        end

        params
          .merge(date_to_params(article.date))
          .merge(lang: article.lang.to_s, locale: article.locale.to_s, title: article.slug)
      end

      ##
      # Create an alias page resource that redirects to the main article
      #
      # @param  alias_path [String] The path for the alias
      # @param  article    [BlogArticle] The target article
      # @return [Sitemap::Resource] A redirect resource
      ##
      def alias_page_resource(alias_path, article)
        target_url = article.destination_path
        # Ensure target URL starts with '/' for absolute URLs
        target_url = "/#{target_url}" unless target_url.start_with?('/')
        AliasResource.new(@sitemap, alias_path, target_url, article)
      end
    end

    ##
    # A resource that generates redirect HTML for alias pages
    ##
    class AliasResource < ::Middleman::Sitemap::Resource
      def initialize(store, path, target_url, alias_resource)
        @target_url = target_url
        @alias_resource = alias_resource
        super(store, path)
      end

      def source_file
        @alias_resource.source_file
      end

      def template?
        false
      end

      def render(*args, &block)
        %[
          <html>
            <head>
              <link rel="canonical" href="#{@target_url}" />
              <meta name="robots" content="noindex,follow" />
              <meta http-equiv="cache-control" content="no-cache" />
              <script>
                // Attempt to keep search and hash
                window.location.replace("#{@target_url}"+window.location.search+window.location.hash);
              </script>
              <meta http-equiv=refresh content="0; url=#{@target_url}" />
            </head>
            <body>
              <a href="#{@target_url}">You are being redirected.</a>
            </body>
          </html>
        ]
      end

      def binary?
        false
      end

      def raw_data
        @alias_resource.raw_data
      end

      def ignored?
        false
      end

      def metadata
        @alias_resource.metadata
      end
    end
  end
end