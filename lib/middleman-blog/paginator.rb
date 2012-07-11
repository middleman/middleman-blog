module Middleman
  module Blog

    # A sitemap plugin that splits indexes (including tag
    # and calendar indexes) over multiple pages
    class Paginator
      def initialize(app)
        @app = app
      end

      # Substitute the page number into the resource URL.
      # @return [String]
      def page_sub(res, num, page_link)
        if num == 1
          # First page has an unmodified URL.
          res.path
        else
          page_url = page_link.sub(":num", num.to_s)
          index_re = %r{/#{Regexp.escape(@app.index_file)}$}
          if res.path =~ index_re
            res.path.sub(index_re, "/#{page_url}/#{@app.index_file}")
          else
            res.path.sub(%r{/([^/]*)\.([^/]*)$}, "/\\1/#{page_url}.\\2")
          end
        end
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        new_resources = []

        resources.each do |res|
          next if res.ignored?

          md = res.metadata
          if md[:page]["pageable"]
            # "articles" local variable is populated by Calendar and Tag page generators
            # If it's not set then use the complete list of articles
            # TODO: Some way to allow the frontmatter to specify the article filter?
            articles = md[:locals]["articles"] || @app.blog.articles

            # Allow blog.per_page and blog.page_link to be overridden in the frontmatter
            per_page  = md[:page]["per_page"] || @app.blog.options.per_page
            page_link = md[:page]["page_link"] || @app.blog.options.page_link

            num_pages = (articles.length / per_page.to_f).ceil

            # Add the pagination metadata to the base page (page 1)
            res.add_metadata :locals => {
              # Set a flag to allow templates to be used with and without pagination
              'paginate' => true,

              # Include the numbers, useful for displaying "Page X of Y"
              'page_number' => 1,
              'num_pages' => num_pages,
              'per_page' => per_page,

              # Indexes into the article list for which articles appear on this page
              'page_start' => 0,
              'page_end' => per_page-1,

              # These contain the URL for the next and previous page.
              # They are set to nil if there are no more pages.
              'next_page' => num_pages > 1 ? page_sub(res, 2, page_link) : nil,
              'prev_page' => nil,

              # Include the articles so that non-proxied pages can use "articles" instead
              # of "blog.articles" for consistency with the calendar and tag templates.
              'articles' => articles
            }

            # Create additional resources for the 2nd and subsequent pages.
            (2..num_pages).each do |num|
              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                page_sub(res, num, page_link),
                res.source_file
              )

              # Copy the metadata from the base PAge
              p.add_metadata md

              # Add pagination metadata, meanings as above.
              p.add_metadata :locals => {
                'paginate' => true,
                'page_number' => num,
                'num_pages' => num_pages,
                'per_page' => per_page,
                'page_start' => (num-1)*per_page,
                'page_end' => (num*per_page)-1,
                'next_page' => num < num_pages ? page_sub(res, num+1, page_link) : nil,
                'prev_page' => page_sub(res, num-1, page_link),
                'articles' => articles
              }

              new_resources << p
            end
          end
        end

        resources + new_resources
      end
    end
  end
end
