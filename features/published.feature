Feature: Unpublished blog articles
  Scenario: Unpublished articles show up in the preview server
    Given the Server is running at "published-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/2012/06/19/draft-article.html"
    Then I should see "This is a draft"
    When I go to "/2012/06/19/draft-article/example.txt"
    Then I should see "Example Text"

  Scenario: Unpublished articles don't show up when the environment is not :development
    Given a fixture app "published-app"
    And a file named "config.rb" with:
      """
      set :environment, :production
      activate :blog do |blog|
        blog.sources = "blog/:year-:month-:day-:title.html"
      end
      """
    Given the Server is running at "published-app"
    When I go to "/2012/06/19/draft-article.html"
    Then I should see "Not Found"
    When I go to "/2012/06/19/draft-article/example.txt"
    Then I should see "Not Found"

  Scenario: Unpublished articles don't get built
    Given a successfully built app at "published-app"
    When I cd to "build"
    Then the following files should not exist:
      | 2012/06/19/draft-article.html        |
      | 2012/06/19/draft-article/example.txt |
    Then the following files should exist:
      | 2011/01/01/new-article.html          |
