require 'middleman-blog/uri_templates'

module Middleman

  module Blog

    ##
    # A store of all the blog articles in the site, with accessors
    # for the articles by various dimensions. Accessed via "blog" in
    # templates.
    ##
    class BlogData

      include UriTemplates
      extend Gem::Deprecate

      # A URITemplate for the source file path relative to :source_dir
      # @return [URITemplate]
      attr_reader :source_template

      # The configured options for this blog
      # @return [Thor::CoreExt::HashWithIndifferentAccess]
      attr_reader :options

      attr_reader :controller

      ##
      # @private
      ##
      def initialize(app, controller, options)
        @app        = app
        @options    = options
        @controller = controller

        # A list of resources corresponding to blog articles
        @_articles = []

        @_parsed_url_cache = {
          source: {},
          subdir: {}
        }

        @source_template           = uri_template options.sources
        @permalink_template        = uri_template options.permalink
        @subdir_template           = uri_template options.sources.sub(/(\.[^.{}\/]+)?$/, "/{+path}" )
        @subdir_permalink_template = uri_template options.permalink.sub(/(\.[^.{}\/]+)?$/, "/{+path}" )
      end

      ##
      # A list of all blog articles, sorted by descending date
      #
      # @return [Array<Middleman::Sitemap::Resource>]
      ##
      def articles
        @_articles.select( &( options.filter || proc { | a | a } ) ).sort_by( &:date ).reverse
      end

      ##
      # A list of all blog articles with the given language, sorted by
      # descending date
      #
      # @deprecated Use {#articles_by_locale} instead.
      #
      # @param  [Symbol] locale Language to match (optional, defaults to I18n.locale).
      # @return [Array<Middleman::Sitemap::Resource>]
      ##
      def local_articles( locale = ::I18n.locale )
          articles_by_locale( locale )
      end
      deprecate :local_articles, :articles_by_locale, 2017, 5

      ##
      # A list of all blog articles with the given language, sorted by
      # descending date
      #
      # @param  [Symbol] locale Language to match (optional, defaults to I18n.locale).
      # @return [Array<Middleman::Sitemap::Resource>]
      #
      # @todo should use the @_articles if represented in this method.
      ##
      def articles_by_locale( locale = ::I18n.locale )
        locale = locale.to_sym if locale.kind_of? String
        articles.select { | article | article.locale == locale }
      end

      ##
      # Returns a map from tag name to an array of BlogArticles associated with
      # that tag and assigns the tag array back into it.
      #
      # @return [Hash<String, Array<Middleman::Sitemap::Resource>>]
      ##
      def tags

        tags = {}

        # Reference the filtered articles
        articles.each do |article|

          # Reference the tags assigned to an article
          article.tags.each do |tag|
            tag = safe_parameterize(tag)
            tags[tag] ||= []
            tags[tag] << article
          end

        end

        # Return tags
        tags
      end

      ##
      #
      ##
      def extract_source_params(path)
        @_parsed_url_cache[:source][path] ||= extract_params(@source_template, path)
      end

      ##
      #
      ##
      def extract_subdir_params(path)
        @_parsed_url_cache[:subdir][path] ||= extract_params(@subdir_template, path)
      end

      ##
      # Updates' blog articles destination paths to be the permalink.
      #
      # @return [void]
      ##
      def manipulate_resource_list(resources)
        @_articles = []
        used_resources = []

        resources.each do |resource|
          if resource.ignored?
            # Don't bother blog-processing ignored stuff
            used_resources << resource
            next
          end

          if (params = extract_source_params(resource.path))
            article = convert_to_article(resource)
            next unless publishable?(article)

            # Add extra parameters from the URL to the page metadata
            extra_data = params.except *%w(year month day title lang locale)
            article.add_metadata page: extra_data unless extra_data.empty?

            # compute output path: substitute date parts to path pattern
            article.destination_path = template_path @permalink_template, article, extra_data

            @_articles << article

          elsif (params = extract_subdir_params(resource.path))
            # It's not an article, but it's the companion files for an article
            # (in a subdirectory named after the article)
            # figure out the matching article for this subdirectory file
            article_path = @source_template.expand(params).to_s

            if article = @app.sitemap.find_resource_by_path(article_path)
              # The article may not yet have been processed, so convert it here.
              article = convert_to_article(article)
              next unless publishable?(article)

              # Add extra parameters from the URL to the page metadata
              extra_data = params.except *%w(year month day title lang locale)
              article.add_metadata page: extra_data unless extra_data.empty?

              # The subdir path is the article path with the index file name
              # or file extension stripped off.
              new_destination_path = template_path @subdir_permalink_template, article, extra_data

              resource.destination_path = Middleman::Util.normalize_path(new_destination_path)
            end
          end

          used_resources << resource
        end

        used_resources
      end

      ##
      #
      ##
      def inspect
        "#<Middleman::Blog::BlogData: #{articles.inspect}>"
      end

      ##
      # Whether or not a given article should be included in the sitemap.
      # Skip articles that are not published unless the environment is +:development+.
      #
      # @param [BlogArticle] article A blog article
      # @return [Boolean] whether it should be published
      ##
      def publishable?(article)
        @app.environment == :development || article.published?
      end

      private

      ##
      # Generate a hash of options for substituting into the permalink URL template.
      #
      # @param [Sitemap::Resource] resource The resource to generate options for.
      # @param [Hash] extra More options to be merged in on top.
      # @return [Hash] options
      ##
      def permalink_options(resource, extra={})
        # Allow any frontmatter data to be substituted into the permalink URL
        params = resource.metadata[:page].slice *@permalink_template.variables.map(&:to_sym)

        params.each do |k, v|
          params[k] = safe_parameterize(v)
        end

        params.
          merge(date_to_params(resource.date)).
          merge(lang: resource.lang.to_s, locale: resource.locale.to_s, title: resource.slug).
          merge(extra)
      end

      ##
      #
      ##
      def convert_to_article( resource )
        return resource if resource.is_a?( BlogArticle )

        resource.extend BlogArticle
        resource.blog_controller = controller

        if !options.preserve_locale && (locale = resource.locale || resource.lang)
          resource.add_metadata options: { lang: locale, locale: locale }, locals: { lang: locale, locale: locale }
        end

        resource
      end

      ##
      #
      ##
      def template_path(template, article, extras={})
        apply_uri_template template, permalink_options(article, extras)
      end

    end
  end
end
