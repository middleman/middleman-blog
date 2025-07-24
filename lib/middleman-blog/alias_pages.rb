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
        # Allow any frontmatter data to be substituted into the permalink URL
        page_data = article.metadata[:page] || {}
        params = page_data.slice(*template_variables.map(&:to_sym))

        params.each do |k, v|
          params[k] = safe_parameterize(v)
        end

        params
          .merge(date_to_params(article.date))
          .merge(lang: article.lang.to_s, locale: article.locale.to_s, title: article.slug)
      end

      ##
      # Get all template variables from all alias templates
      #
      # @return [Array<String>] Variable names
      ##
      def template_variables
        @template_variables ||= @alias_templates.flat_map(&:variables).uniq
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

        # Create the redirect HTML content
        redirect_content = <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="utf-8">
            <title>Redirecting...</title>
            <meta http-equiv="refresh" content="0; url=#{target_url}">
            <link rel="canonical" href="#{target_url}">
          </head>
          <body>
            <p>Redirecting to <a href="#{target_url}">#{target_url}</a>...</p>
            <script>window.location.href = "#{target_url}";</script>
          </body>
          </html>
        HTML

        # Create a proxy resource that returns our redirect content
        Sitemap::ProxyResource.new(@sitemap, alias_path, nil).tap do |resource|
          # Override the render method to return redirect content
          resource.define_singleton_method(:render) do |*args|
            redirect_content
          end

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