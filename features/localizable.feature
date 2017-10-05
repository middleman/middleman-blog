@wip
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
