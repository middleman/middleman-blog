module Middleman
  module Blog
    # A store of all the blog articles in the site, with accessors
    # for the articles by various dimensions. Accessed via "blog" in
    # templates.
    class BlogData
      # A regex for matching blog article source paths
      # @return [Regex]
      attr_reader :path_matcher
      
      # The configured options for this blog
      # @return [Thor::CoreExt::HashWithIndifferentAccess]
      attr_reader :options

      # @private
      def initialize(app, options={})
        @app = app
        @options = options

        # A list of resources corresponding to blog articles
        @_articles = []
        
        matcher = Regexp.escape(options.sources).
            sub(/^\//, "").
            sub(":year",  "(\\d{4})").
            sub(":month", "(\\d{2})").
            sub(":day",   "(\\d{2})").
            sub(":title", "(.*)")

        @path_matcher = /^#{matcher}/
      end

      # A list of all blog articles, sorted by descending date
      # @return [Array<Middleman::Sitemap::Resource>]
      def articles
        @_articles.sort_by(&:date).reverse
      end

      # The BlogArticle for the given path, or nil if one doesn't exist.
      # @return [Middleman::Sitemap::Resource]
      def article(path)
        article = @app.sitemap.find_resource_by_path(path.to_s)
        if article && article.is_a?(BlogArticle)
          article
        else
          nil
        end
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

        resources.each do |resource|
          if resource.path =~ path_matcher
            resource.extend BlogArticle
            resource.slug = $4
            
            # compute output path:
            #   substitute date parts to path pattern
            resource.destination_path = options.permalink.
              sub(':year', resource.date.year.to_s).
              sub(':month', resource.date.month.to_s.rjust(2,'0')).
              sub(':day', resource.date.day.to_s.rjust(2,'0')).
              sub(':title', resource.slug)

            resource.destination_path = Middleman::Util.normalize_path(resource.destination_path)

            @_articles << resource
          end
        end
      end
    end
  end
end
