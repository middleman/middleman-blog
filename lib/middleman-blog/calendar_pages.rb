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
          if @app.blog.year_template
            @app.ignore @app.blog.year_template

            path = Middleman::Util.normalize_path(@app.blog_year_path(year))
          
            p = ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              path
            )
            p.proxy_to(@app.blog.year_template)

            set_locals_year = Proc.new do
              @year = year
              @articles = year_articles
            end

            @app.sitemap.provides_metadata_for_path path, :blog_calendar do |path|
              { :blocks => set_locals_year }
            end

            new_resources << p
          end
            
          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if @app.blog.month_template
              @app.ignore @app.blog.month_template

              path = Middleman::Util.normalize_path(@app.blog_month_path(year, month))
          
              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                path
              )
              p.proxy_to(@app.blog.month_template)

              set_locals_month = Proc.new do
                @year = year
                @month = month
                @articles = month_articles
              end

              @app.sitemap.provides_metadata_for_path path, :blog_calendar do |path|
                { :blocks => [ set_locals_month ] }
              end

              new_resources << p
            end
            
            month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
              if @app.blog.day_template
                @app.ignore @app.blog.day_template

                path = Middleman::Util.normalize_path(@app.blog_day_path(year, month, day))
                p = ::Middleman::Sitemap::Resource.new(
                  @app.sitemap,
                  path
                )
                p.proxy_to(@app.blog.month_template)

                set_locals_day = Proc.new do
                  @year = year
                  @month = month
                  @day = day
                  @articles = day_articles
                end

                @app.sitemap.provides_metadata_for_path path, :blog_calendar do |path|
                  { :blocks => [ set_locals_day ] }
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
