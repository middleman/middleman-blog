require 'set'

module Middleman
  module Blog
    # A store of all the blog articles in the site, with accessors
    # for the articles by various dimensions. Accessed via "blog" in
    # templates.
    class BlogData
      # A regex for matching blog article source paths
      # @return [Regex]
      attr_reader :path_matcher

      # A hash of indexes into the path_matcher captures
      # @return [Hash]
      attr_reader :matcher_indexes

      # The configured options for this blog
      # @return [Thor::CoreExt::HashWithIndifferentAccess]
      attr_reader :options

      attr_reader :controller

      DEFAULT_PERMALINK_COMPONENTS = Set.new [:lang, :year, :month, :day, :title]

      # @private
      def initialize(app, controller, options)
        @app = app
        @options = options
        @controller = controller

        # A list of resources corresponding to blog articles
        @_articles = []

        # TODO: replace with uri_template
        matcher = Regexp.escape(options.sources).
            sub(/^\//, "").
            gsub(":lang",  "(\\w{2}(?:-\\w{2})?)").
            gsub(":year",  "(\\d{4})").
            gsub(":month", "(\\d{2})").
            gsub(":day",   "(\\d{2})").
            sub(":title", "([^/]+)")

        subdir_matcher = matcher.sub(/\\\.[^.]+$/, "(/.*)$")

        @path_matcher = /^#{matcher}/
        @subdir_matcher = /^#{subdir_matcher}/

        # Build a hash of part name to capture index, e.g. {"year" => 0}
        @matcher_indexes = {}
        # This is a regexp like /:lang|:year|:month/, etc
        component_regexp = Regexp.union(DEFAULT_PERMALINK_COMPONENTS.map(&:inspect))
        options.sources.scan(component_regexp).each_with_index do |key, i|
            @matcher_indexes[key[1..-1]] = i
        end
        # The path always appears at the end.
        @matcher_indexes["path"] = @matcher_indexes.size
      end

      # A list of all blog articles, sorted by descending date
      # @return [Array<Middleman::Sitemap::Resource>]
      def articles
        @_articles.sort_by(&:date).reverse
      end

      # A list of all blog articles with the given language,
      # sorted by descending date
      #
      # @param [Symbol] lang Language to match (optional, defaults to I18n.locale).
      # @return [Array<Middleman::Sitemap::Resource>]
      def local_articles(lang=nil)
        lang ||= I18n.locale
        lang = lang.to_sym if lang.kind_of? String
        articles.select {|article| article.lang == lang }
      end

      # Returns a map from tag name to an array
      # of BlogArticles associated with that tag.
      # @return [Hash<String, Array<Middleman::Sitemap::Resource>>]
      def tags
        tags = {}
        @_articles.each do |article|
          article.tags.each do |tag|
            tags[tag] ||= []
            tags[tag] << article
          end
        end

        # Sort each tag's list of articles
        tags.each do |tag, articles|
          tags[tag] = articles.sort_by(&:date).reverse
        end

        tags
      end

      # Updates' blog articles destination paths to be the
      # permalink.
      # @return [void]
      def manipulate_resource_list(resources)
        @_articles = []
        used_resources = []

        resources.each do |resource|
          if resource.path =~ path_matcher
            article = convert_to_article(resource)
            next unless publishable?(article)

            # compute output path:
            #   substitute date parts to path pattern
            article.destination_path = Middleman::Util.normalize_path parse_permalink_options(article)

            @_articles << article

          elsif resource.path =~ @subdir_matcher
            # It's not an article, but it's thhe companion files for an article
            # (in a subdirectory named after the article)

            match = $~.captures

            # figure out the matching article for this subdirectory file
            article_path = options.sources
            DEFAULT_PERMALINK_COMPONENTS.each do |token|
              index = @matcher_indexes[token.to_s]
              article_path = article_path.gsub(token.inspect, match[index]) if index
            end

            article = @app.sitemap.find_resource_by_path(article_path)
            raise "Article for #{resource.path} not found" if article.nil?

            # The article may not yet have been processed, so convert it here.
            article = convert_to_article(article)
            next unless publishable?(article)

            # The subdir path is the article path with the index file name
            # or file extension stripped off.
            new_destination_path = parse_permalink_options(article).
              sub(/(\/#{@app.index_file}$)|(\.[^.]+$)|(\/$)/, match[@matcher_indexes["path"]])

            resource.destination_path = Middleman::Util.normalize_path(new_destination_path)
          end

          used_resources << resource
        end

        used_resources
      end

      def inspect
        "#<Middleman::Blog::BlogData: #{articles.inspect}>"
      end

      # Skip articles that are not published (in non-development environments)
      # @param [BlogArticle] a blog article
      # @return [Boolean] whether it should be published
      def publishable?(article)
        @app.environment == :development || article.published?
      end

      private

      def parse_permalink_options(resource)
        permalink = options.permalink.
          gsub(':lang', resource.lang.to_s).
          gsub(':year', resource.date.year.to_s).
          gsub(':month', resource.date.month.to_s.rjust(2, '0')).
          gsub(':day', resource.date.day.to_s.rjust(2, '0')).
          sub(':title', resource.slug)

        custom_permalink_components.each do |component|
          permalink = permalink.sub(component.inspect, resource.data[component.to_s].parameterize)
        end

        permalink
      end

      def custom_permalink_components
        permalink_url_components - DEFAULT_PERMALINK_COMPONENTS
      end

      def permalink_url_components
        Set.new options.permalink.scan(/:([A-Za-z0-9]+)/).flatten.map(&:to_sym)
      end

      def convert_to_article(resource)
        return resource if resource.is_a?(BlogArticle)

        resource.extend BlogArticle
        resource.blog_controller = controller

        if !options.preserve_locale && (lang = resource.lang)
          resource.add_metadata(:options => { :lang => lang }, :locals => { :lang => lang })
        end

        resource
      end
    end
  end
end
