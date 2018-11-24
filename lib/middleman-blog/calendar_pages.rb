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
        @generate_year_pages = blog_options.generate_year_pages
        @generate_month_pages = blog_options.generate_month_pages
        @generate_day_pages = blog_options.generate_day_pages
      end

      # Get a path to the given calendar page, based on the :year_link, :month_link or :day_link setting.
      # @param [Number] year
      # @param [Number] month
      # @param [Number] day
      # @return [String]
      def link(year, month=nil, day=nil, locale: nil)
        template = if day
                     @day_link_template
                   elsif month
                     @month_link_template
                   else
                     @year_link_template
                   end

        link = apply_uri_template template, date_to_params(Date.new(year, month || 1, day || 1))

        if locale && i18n = @blog_controller.app.extensions[:i18n]
          link = i18n.path_root(locale)[1..-1] + link
        end

        link
      end

      # Update the main sitemap resource list
      # @return [Array<Middleman::Sitemap::Resource>]
      def manipulate_resource_list(resources)
        resources + calendar_pages(@blog_data.articles)
      end

      private

      def calendar_pages(articles, locale = :recurse)
        if locale == :recurse
          if @blog_controller.options.localizable
            return articles.group_by(&:locale).map { |l, a| calendar_pages(a, l) }.flatten
          else
            return calendar_pages(articles, nil)
          end
        end

        new_resources = []

        # Set up date pages if the appropriate templates have been specified
        articles.group_by {|a| a.date.year }.each do |year, year_articles|
          if @generate_year_pages && @year_template
            new_resources << year_page_resource(year, year_articles, locale)
          end

          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if @generate_month_pages && @month_template
              new_resources << month_page_resource(year, month, month_articles, locale)
            end

            month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
              if @generate_day_pages && @day_template
                new_resources << day_page_resource(year, month, day, day_articles, locale)
              end
            end
          end
        end

        new_resources
      end

      def year_page_resource(year, year_articles, locale=nil)
        Sitemap::ProxyResource.new(@sitemap, link(year, locale: locale), @year_template).tap do |p|
          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'year',
            'year' => year,
            'articles' => year_articles,
            'blog_controller' => @blog_controller
          }

          p.add_metadata(options: { locale: locale }) if locale
        end
      end

      def month_page_resource(year, month, month_articles, locale=nil)
        Sitemap::ProxyResource.new(@sitemap, link(year, month, locale: locale), @month_template).tap do |p|
          p.add_metadata locals: {
            'page_type' => 'month',
            'year' => year,
            'month' => month,
            'articles' => month_articles,
            'blog_controller' => @blog_controller
          }

          p.add_metadata(options: { locale: locale }) if locale
        end
      end

      def day_page_resource(year, month, day, day_articles, locale=nil)
        Sitemap::ProxyResource.new(@sitemap, link(year, month, day, locale: locale), @day_template).tap do |p|
          p.add_metadata locals: {
            'page_type' => 'day',
            'year' => year,
            'month' => month,
            'day' => day,
            'articles' => day_articles,
            'blog_controller' => @blog_controller
          }

          p.add_metadata(options: { locale: locale }) if locale
        end
      end
    end
  end
end
