module Middleman
  module Blog

    # A sitemap plugin that adds month/day/year pages to the sitemap
    # based on the dates of blog articles.
    class CalendarPages
      class << self
        # Get a path to the given calendar page, based on the :year_link, :month_link or :day_link setting.
        # @param [Middleman::Application] app
        # @param [Number] year
        # @param [Number] month
        # @param [Number] day
        # @return [String]
        def link(app, year, month=nil, day=nil)
          path = if day
                   app.blog.options.day_link.
                     sub(':year', year.to_s).
                     sub(':month', month.to_s.rjust(2,'0')).
                     sub(':day', day.to_s.rjust(2,'0'))
                 elsif month
                   app.blog.options.month_link.
                     sub(':year', year.to_s).
                     sub(':month', month.to_s.rjust(2,'0'))
                 else
                   app.blog.options.year_link.
                     sub(':year', year.to_s)
                 end
          ::Middleman::Util.normalize_path(path)
        end
      end

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

            path = CalendarPages.link(@app, year)
          
            p = ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              path
            )
            p.proxy_to(@app.blog.options.year_template)

            # Add metadata in local variables so it's accessible to
            # later extensions
            p.add_metadata :locals => {
              'page_type' => 'year',
              'year' => year,
              'articles' => year_articles
            }
            # Add metadata in instance variables for backwards compatibility
            p.add_metadata do
              @year = year
              @articles = year_articles
            end

            new_resources << p
          end
            
          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if @app.blog.options.month_template
              @app.ignore @app.blog.options.month_template

              path = CalendarPages.link(@app, year, month)
          
              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                path
              )
              p.proxy_to(@app.blog.options.month_template)

              p.add_metadata :locals => {
                'page_type' => 'month',
                'year' => year,
                'month' => month,
                'articles' => month_articles
              }
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

                path = CalendarPages.link(@app, year, month, day)

                p = ::Middleman::Sitemap::Resource.new(
                  @app.sitemap,
                  path
                )
                p.proxy_to(@app.blog.options.day_template)

                p.add_metadata :locals => {
                  'page_type' => 'day',
                  'year' => year,
                  'month' => month,
                  'day' => day,
                  'articles' => day_articles
                }
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
