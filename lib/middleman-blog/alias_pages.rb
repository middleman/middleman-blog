# frozen_string_literal: true

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
        @redirect_template = File.expand_path('templates/redirect.html.erb', __dir__)
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
          .merge(lang: (article.lang || '').to_s, locale: (article.locale || '').to_s, title: article.slug)
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

        # Create a proxy resource that uses our redirect template
        Sitemap::ProxyResource.new(@sitemap, alias_path, @redirect_template).tap do |resource|
          resource.add_metadata(
            locals: {
              'redirect_to' => target_url,
              'page_type' => 'alias'
            }
          )
        end
      end
    end
  end
end