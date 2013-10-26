Feature: Public draft articles
  Scenario: Public draft articles show up in the preview server
    Given the Server is running at "public-draft-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/2012/06/19/draft-article.html"
    Then I should see "This is a draft"
    When I go to "/2012/06/19/draft-article/example.txt"
    Then I should see "Example Text"
    When I go to "/"
    Then I should see "Newer Article Content"
    Then I should see "This is a draft"

  Scenario: Public draft articles are not listed when the environment is not :development
    Given a fixture app "public-draft-app"
    And a file named "config.rb" with:
      """
      set :environment, :production
      activate :blog do |blog|
        blog.sources = "blog/:year-:month-:day-:title.html"
      end
      """
    Given the Server is running at "public-draft-app"
    When I go to "/"
    Then I should see "Newer Article Content"
    Then I should not see "This is a draft"

  Scenario: Public draft articles are accessible when the environment is not :development
    Given a fixture app "public-draft-app"
    And a file named "config.rb" with:
      """
      set :environment, :production
      activate :blog do |blog|
        blog.sources = "blog/:year-:month-:day-:title.html"
      end
      """
    Given the Server is running at "public-draft-app"
    When I go to "/2012/06/19/draft-article.html"
    Then I should see "This is a draft"
    When I go to "/2012/06/19/draft-article/example.txt"
    Then I should see "Example Text"

  Scenario: Public draft arcticles get built
    Given a successfully built app at "public-draft-app"
    When I cd to "build"
    Then the following files should exist:
      | 2012/06/19/draft-article.html        |
      | 2012/06/19/draft-article/example.txt |
      | 2011/01/01/new-article.html          |
