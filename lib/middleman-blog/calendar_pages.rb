require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap plugin that adds month/day/year pages to the sitemap
    # based on the dates of blog articles.
    class CalendarPages
      include UriTemplates

      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_controller = blog_controller
        @blog_data = blog_controller.data

        blog_options = blog_controller.options
        @day_link_template = uri_template blog_options.day_link
        @month_link_template = uri_template blog_options.month_link
        @year_link_template = uri_template blog_options.year_link
        @day_template = blog_options.day_template
        @month_template = blog_options.month_template
        @year_template = blog_options.year_template
      end

      # Get a path to the given calendar page, based on the :year_link, :month_link or :day_link setting.
      # @param [Number] year
      # @param [Number] month
      # @param [Number] day
      # @return [String]
      def link(year, month=nil, day=nil)
        template = if day
                     @day_link_template
                   elsif month
                     @month_link_template
                   else
                     @year_link_template
                   end

        apply_uri_template template, date_to_params(Date.new(year, month || 1, day || 1))
      end

      # Update the main sitemap resource list
      # @return [Array<Middleman::Sitemap::Resource>]
      def manipulate_resource_list(resources)
        new_resources = []

        # Set up date pages if the appropriate templates have been specified
        @blog_data.articles.group_by {|a| a.date.year }.each do |year, year_articles|
          if @year_template
            new_resources << year_page_resource(year, year_articles)
          end

          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if @month_template
              new_resources << month_page_resource(year, month, month_articles)
            end

            month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
              if @day_template
                new_resources << day_page_resource(year, month, day, day_articles)
              end
            end
          end
        end

        resources + new_resources
      end

      private

      def year_page_resource(year, year_articles)
        Sitemap::Resource.new(@sitemap, link(year)).tap do |p|
          p.proxy_to(@year_template)

          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'year',
            'year' => year,
            'articles' => year_articles,
            'blog_controller' => @blog_controller
          }
        end
      end

      def month_page_resource(year, month, month_articles)
        Sitemap::Resource.new(@sitemap, link(year, month)).tap do |p|
          p.proxy_to(@month_template)

          p.add_metadata locals: {
            'page_type' => 'month',
            'year' => year,
            'month' => month,
            'articles' => month_articles,
            'blog_controller' => @blog_controller
          }
        end
      end

      def day_page_resource(year, month, day, day_articles)
        Sitemap::Resource.new(@sitemap, link(year, month, day)).tap do |p|
          p.proxy_to(@day_template)

          p.add_metadata locals: {
            'page_type' => 'day',
            'year' => year,
            'month' => month,
            'day' => day,
            'articles' => day_articles,
            'blog_controller' => @blog_controller
          }
        end
      end
    end
  end
end
