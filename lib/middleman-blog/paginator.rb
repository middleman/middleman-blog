require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap plugin that splits indexes (including tag
    # and calendar indexes) over multiple pages
    class Paginator
      include UriTemplates

      def initialize(app, blog_controller)
        @app = app
        @blog_controller = blog_controller
        @per_page = blog_controller.options.per_page
        @page_link = blog_controller.options.page_link
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        new_resources = []

        resources.each do |res|
          next if res.ignored?

          # Avoid recomputing metadata over and over
          md = res.metadata

          next unless md[:page]["pageable"]

          # Skip other blogs' resources
          next unless match_blog(res, md)

          # "articles" local variable is populated by Calendar and Tag page generators
          # If it's not set then use the complete list of articles
          # TODO: Some way to allow the frontmatter to specify the article filter?
          articles = md[:locals]["articles"] || @blog_controller.data.articles

          # Allow blog.per_page and blog.page_link to be overridden in the frontmatter
          per_page  = md[:page]["per_page"] || @per_page
          page_link = uri_template(md[:page]["page_link"] || @page_link)

          num_pages = (articles.length / per_page.to_f).ceil

          # Add the pagination metadata to the base page (page 1)
          res.add_metadata locals: page_locals(1, num_pages, per_page, nil, articles)

          prev_page_res = res

          # Create additional resources for the 2nd and subsequent pages.
          2.upto(num_pages) do |page_num|
            p = page_resource(res, page_num, page_link)

            # Copy the metadata from the base page
            p.add_metadata md
            p.add_metadata locals: page_locals(page_num, num_pages, per_page, prev_page_res, articles)

            # Add a reference in the previous page to this page
            prev_page_res.add_metadata locals: { 'next_page' => p }

            prev_page_res = p

            new_resources << p
          end
        end

        resources + new_resources
      end

      private

      # Does this resource match the blog controller for this paginator?
      # @return [Boolean]
      def match_blog(res, md)
        res_controller = md[:locals]["blog_controller"] || (res.respond_to?(:blog_controller) && res.blog_controller)
        return false if res_controller && res_controller != @blog_controller
        override_controller = md[:page]["blog"]
        return false if override_controller && override_controller.to_s != @blog_controller.name.to_s

        true
      end

      # Generate a resource for a particular page
      # @param [Sitemap::Resource] res the original resource
      # @param [Integer] page_num the page number to generate a resource for
      # @param [String] page_link The pagination link path component template
      def page_resource(res, page_num, page_link)
        path = page_sub(res, page_num, page_link)
        Sitemap::Resource.new(@app.sitemap, path, res.source_file).tap do |p|
          # Copy the proxy state from the base page.
          p.proxy_to(res.proxied_to) if res.proxy?
        end
      end

      # @param [Integer] page_num the page number to generate a resource for
      # @param [Integer] num_pages Total number of pages
      # @param [Integer] per_page How many articles per page
      # @param [Sitemap::Resource] prev_page_res The resource of the previous page
      # @param [Array<Sitemap::Resource>] articles The list of all articles
      def page_locals(page_num, num_pages, per_page, prev_page_res, articles)
        # Index into articles of the first article of this page
        page_start = (page_num - 1) * per_page

        # Index into articles of the last article of this page
        page_end = (page_num * per_page) - 1

        {
          # Set a flag to allow templates to be used with and without pagination
          'paginate' => true,

          # Include the numbers, useful for displaying "Page X of Y"
          'page_number' => page_num,
          'num_pages' => num_pages,
          'per_page' => per_page,

          # The range of article numbers on this page
          # (1-based, for showing "Items X to Y of Z")
          'page_start' => page_start + 1,
          'page_end' => [page_end + 1, articles.length].min,

          # These contain the next and previous page.
          # They are set to nil if there are no more pages.
          # The nils are overwritten when the later pages are generated, below.
          'next_page' => nil,
          'prev_page' => prev_page_res,

          # The list of articles for this page.
          'page_articles' => articles[page_start..page_end],

          # Include the articles so that non-proxied pages can use "articles" instead
          # of "blog.articles" for consistency with the calendar and tag templates.
          'articles' => articles,
          'blog_controller' => @blog_controller
        }
      end

      # Substitute the page number into the resource URL.
      # @param [Middleman::Sitemap::Resource] res The resource to generate pages for
      # @param [Integer] page_num The page page_number
      # @param [String] page_link The pagination link path component template
      # @return [String]
      def page_sub(res, page_num, page_link)
        if page_num == 1
          # First page has an unmodified URL.
          res.path
        else
          page_url = apply_uri_template page_link, num: page_num
          index_re = %r{(^|/)#{Regexp.escape(@app.index_file)}$}
          if res.path =~ index_re
            res.path.sub(index_re, "\\1#{page_url}/#{@app.index_file}")
          else
            res.path.sub(%r{(^|/)([^/]*)\.([^/]*)$}, "\\1\\2/#{page_url}.\\3")
          end
        end
      end
    end
  end
end
