Feature: Localizable blog

    Scenario: Article list is scoped to a single language
        Given the Server is running at "localizable-app"

            When I go to "/index.html"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/ru/index.html"
            Then I should see "Январь"
            And I should not see "January"


    Scenario: Paginated article list is scoped to a single language
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n
                  activate :blog, localizable: true, permalink: '{title}.html', paginate: true

                  ignore 'templates/*'
                  """

          Given the Server is running at "localizable-app"

            When I go to "/index.html"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/ru/index.html"
            Then I should see "Январь"
            And I should not see "January"


    Scenario: Non-default locale article paths are prefixed when mount_at_root is used
        Given the Server is running at "localizable-app"

            When I go to "/january.html"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/en/january.html"
            Then the status code should be "404"

            When I go to "/ru/january.html"
            Then I should see "Январь"
            And I should not see "January"


    Scenario: All article paths are prefixed with locale when mount_at_root is not used
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n, mount_at_root: false
                  activate :blog, localizable: true, permalink: '{title}.html'

                  ignore 'templates/*'
                  """

          Given the Server is running at "localizable-app"

            When I go to "/january.html"
            Then the status code should be "404"

            When I go to "/en/january.html"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/ru/january.html"
            Then I should see "Январь"
            And I should not see "January"


    Scenario: Paginated tags are separated by locale
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n
                  activate :blog, localizable: true,
                                  paginate: true,
                                  permalink: '{title}.html',
                                  tag_template: 'templates/tag.html'

                  ignore 'templates/*'
                  """

          Given the Server is running at "localizable-app"

            When I go to "/tags/month.html"
            Then I should see "Tag 'month'"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/tags/month/page/2.html"
            Then I should see "Tag 'month'"
            Then I should see "July"
            And I should not see "Июль"

            When I go to "/ru/tags/winter.html"
            Then I should see "Тег 'winter'"
            Then I should see "Январь"
            And I should not see "January"

            When I go to "/ru/tags/month/page/2.html"
            Then I should see "Тег 'month'"
            Then I should see "Июль"
            And I should not see "July"


    Scenario: Tags are separated by locale
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n
                  activate :blog, localizable: true, permalink: '{title}.html', tag_template: 'templates/tag.html'

                  ignore 'templates/*'
                  """

          Given the Server is running at "localizable-app"

            When I go to "/tags/winter.html"
            Then I should see "Tag 'winter'"
            Then I should see "January"
            And I should not see "Январь"

            When I go to "/ru/tags/winter.html"
            Then I should see "Тег 'winter'"
            Then I should see "Январь"
            And I should not see "January"

    Scenario: Calendar pages are separated by locale
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n
                  activate :blog, localizable: true, permalink: '{title}.html', calendar_template: 'templates/calendar.html'

                  ignore 'templates/*'
                  """

          Given a successfully built app at "localizable-app"

            Then the file "build/2017/01.html" should contain "January 2017"
            And the file "build/ru/2017/01.html" should contain "Январь 2017"


    Scenario: Tags links are separated by locale
          Given a fixture app "localizable-app"
              And a file named "config.rb" with:
                  """
                  activate :i18n
                  activate :blog, localizable: true, permalink: '{title}.html', tag_template: 'templates/tag.html', layout: 'article'

                  ignore 'templates/*'
                  """

          Given the Server is running at "localizable-app"

            When I go to "/january.html"
            Then I should see "winter - /tags/winter.html"
            Then I should see "month - /tags/month.html"

            When I go to "/ru/january.html"
            Then I should see "winter - /ru/tags/winter.html"
            Then I should see "month - /ru/tags/month.html"
