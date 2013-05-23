module Middleman
  module Blog

    # A sitemap plugin that adds month/day/year pages to the sitemap
    # based on the dates of blog articles.
    class CalendarPages
      class << self
        # Get a path to the given calendar page, based on the :year_link, :month_link or :day_link setting.
        # @param [Hash] blog_options
        # @param [Number] year
        # @param [Number] month
        # @param [Number] day
        # @return [String]
        def link(blog_options, year, month=nil, day=nil)
          path = if day
                   blog_options.day_link.
                     sub(':year', year.to_s).
                     sub(':month', month.to_s.rjust(2,'0')).
                     sub(':day', day.to_s.rjust(2,'0'))
                 elsif month
                   blog_options.month_link.
                     sub(':year', year.to_s).
                     sub(':month', month.to_s.rjust(2,'0'))
                 else
                   blog_options.year_link.
                     sub(':year', year.to_s)
                 end
          ::Middleman::Util.normalize_path(path)
        end
      end

      def initialize(app, controller=nil)
        @app = app
        @blog_controller = controller
      end

      def blog_data
        if @blog_controller
          @blog_controller.data
        else
          @app.blog
        end
      end

      def blog_options
        if @blog_controller
          @blog_controller.options
        else
          @app.blog.options
        end
      end
      
      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        new_resources = []

        # Set up date pages if the appropriate templates have been specified
        self.blog_data.articles.group_by {|a| a.date.year }.each do |year, year_articles|
          if self.blog_options.year_template
            path = CalendarPages.link(self.blog_options, year)
          
            p = ::Middleman::Sitemap::Resource.new(
              @app.sitemap,
              path
            )
            p.proxy_to(self.blog_options.year_template)

            # Add metadata in local variables so it's accessible to
            # later extensions
            p.add_metadata :locals => {
              'page_type' => 'year',
              'year' => year,
              'articles' => year_articles,
              'blog_controller' => @blog_controller
            }
            # Add metadata in instance variables for backwards compatibility
            p.add_metadata do
              @year = year
              @articles = year_articles
            end

            new_resources << p
          end
            
          year_articles.group_by {|a| a.date.month }.each do |month, month_articles|
            if self.blog_options.month_template
              path = CalendarPages.link(self.blog_options, year, month)
          
              p = ::Middleman::Sitemap::Resource.new(
                @app.sitemap,
                path
              )
              p.proxy_to(self.blog_options.month_template)

              p.add_metadata :locals => {
                'page_type' => 'month',
                'year' => year,
                'month' => month,
                'articles' => month_articles,
                'blog_controller' => @blog_controller
              }
              p.add_metadata do
                @year = year
                @month = month
                @articles = month_articles
              end

              new_resources << p
            end
            
            month_articles.group_by {|a| a.date.day }.each do |day, day_articles|
              if self.blog_options.day_template
                path = CalendarPages.link(self.blog_options, year, month, day)

                p = ::Middleman::Sitemap::Resource.new(
                  @app.sitemap,
                  path
                )
                p.proxy_to(self.blog_options.day_template)

                p.add_metadata :locals => {
                  'page_type' => 'day',
                  'year' => year,
                  'month' => month,
                  'day' => day,
                  'articles' => day_articles,
                  'blog_controller' => @blog_controller
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
