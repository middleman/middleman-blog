module Middleman
  module Blog
    # A store of all the blog articles in the site, with accessors
    # for the articles by various dimensions. Accessed via "blog" in
    # templates.
    class BlogData

      # @private
      def initialize(app)
        @app = app

        # A map from path to BlogArticle
        @_articles = {}
        
        matcher = Regexp.escape(@app.blog_sources).
            sub(/^\//, "").
            sub(":year",  "(\\d{4})").
            sub(":month", "(\\d{2})").
            sub(":day",   "(\\d{2})").
            sub(":title", "(.*)")

        @path_matcher = /^#{matcher}/
      end

      # A list of all blog articles, sorted by date
      # @return [Array<Middleman::Extensions::Blog::BlogArticle>]
      def articles
        @_sorted_articles ||= begin
          @_articles.values.sort do |a, b|
            b.date <=> a.date
          end
        end
      end

      # The BlogArticle for the given path, or nil if one doesn't exist.
      # @return [Middleman::Extensions::Blog::BlogArticle]
      def article(path)
        @_articles[path.to_s]
      end

      # Returns a map from tag name to an array
      # of BlogArticles associated with that tag.
      # @return [Hash<String, Array<Middleman::Extensions::Blog::BlogArticle>>]
      def tags
        @tags ||= begin
          tags = {}
          @_articles.values.each do |article|
          article.tags.each do |tag|
              tags[tag] ||= []
              tags[tag] << article
            end
          end

          tags
        end
      end

      # Updates' blog articles destination paths to be the
      # permalink.
      # @return [void]
      def manipulate_resource_list(resources)
        @_articles = {}

        resources.each do |resource|
          if resource.path =~ @path_matcher
            article = BlogArticle.new(@app, resource)
            article.slug = $4
            
            # compute output path:
            #   substitute date parts to path pattern
            resource.destination_path = @app.blog_permalink.
              sub(':year', article.date.year.to_s).
              sub(':month', article.date.month.to_s.rjust(2,'0')).
              sub(':day', article.date.day.to_s.rjust(2,'0')).
              sub(':title', article.slug)

            resource.destination_path = Middleman::Util.normalize_path(resource.destination_path)

            # TODO: mix in "blogarticle" module?
            # TODO: update blog data (for real?)
            # @app.blog.touch_file(resource.path)
            @_articles[resource.path] = article
          end
        end

        self.update_data

        resources
      end

      protected
      # Clear cached data
      # @private
      def update_data
        @_sorted_articles = nil
        @tags = nil
      end
    end
  end
end
