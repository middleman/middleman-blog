module Middleman
  module Blog

    # A sitemap plugin that adds month/day/year pages to the sitemap
    # based on the dates of blog articles.
    class CalendarPages
      def initialize(app)
        @app = app
      end
      
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        new_resources = []
        # Set up date pages if the appropriate templates have been specified
        @app.blog.articles.group_by {|a| a.date.year }.each do |year, year_articles|
          if @app.blog.options.year_template
            @app.ignore @app.blog.options.year_template

            path = Middleman::Util.normalize_path(@app.blog_year_path(year))
          
            p = ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              path
            )
            p.proxy_to(@app.blog.options.year_template)

            p.add_metadata do
              @year = year
              @articles = year_articles
            end

            new_resources << p
          end
            
          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if @app.blog.options.month_template
              @app.ignore @app.blog.options.month_template

              path = Middleman::Util.normalize_path(@app.blog_month_path(year, month))
          
              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                path
              )
              p.proxy_to(@app.blog.options.month_template)

              p.add_metadata do
                @year = year
                @month = month
                @articles = month_articles
              end

              new_resources << p
            end
            
            month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
              if @app.blog.options.day_template
                @app.ignore @app.blog.options.day_template

                path = Middleman::Util.normalize_path(@app.blog_day_path(year, month, day))
                p = ::Middleman::Sitemap::Resource.new(
                  @app.sitemap,
                  path
                )
                p.proxy_to(@app.blog.options.day_template)

                p.add_metadata do
                  @year = year
                  @month = month
                  @day = day
                  @articles = day_articles
                end

                new_resources << p
              end
            end
          end
        end

        resources + new_resources
      end      
    end
  end
end
