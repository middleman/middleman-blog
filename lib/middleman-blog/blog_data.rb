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

      # Notify the blog store that a particular file has updated
      # @private
      def touch_file(file)
        output_path = @app.sitemap.file_to_path(file)
        if @app.sitemap.exists?(output_path)
          if @_articles.has_key?(output_path)
            @_articles[output_path].update!
          else
            @_articles[output_path] = BlogArticle.new(@app, @app.sitemap.page(output_path))
          end

          self.update_data
        end
      end

      # Notify the blog store that a file has been removed
      # @private
      def remove_file(file)
        output_path = @app.sitemap.file_to_path(file)

        if @_articles.has_key?(output_path)
          @_articles.delete(output_path)
          self.update_data
        end
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
