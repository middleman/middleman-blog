Feature: Future-dated blog articles
  Scenario: Future-dated articles show up in the preview server
    Given the date is 2012-06-18
    And the Server is running at "future-date-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/2012/06/19/future-article.html"
    Then I should see "This is a future-dated article"
    When I go to "/2012/06/19/future-article/example.txt"
    Then I should see "Example Text"

  Scenario: Future-dated articles don't show up when the environment is not :development
    Given a fixture app "future-date-app"
    And a file named "config.rb" with:
      """
      set :environment, :production
      Time.zone = "Pacific Time (US & Canada)"
      activate :blog do |blog|
        blog.sources = "blog/:year-:month-:day-:title.html"
      end
      """
    Given the date is 2012-06-18
    And the Server is running at "future-date-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/2012/06/19/future-article.html"
    Then I should see "Not Found"
    When I go to "/2012/06/19/future-article/example.txt"
    Then I should see "Not Found"

    Given the date is 2012-06-20
    And the Server is running at "future-date-app"
    When I go to "/2012/06/19/future-article.html"
    Then I should see "This is a future-dated article"
    When I go to "/2012/06/19/future-article/example.txt"
    Then I should see "Example Text"

  Scenario: Future-dated articles show up when publish_future_dated is true
    Given a fixture app "future-date-app"
    And a file named "config.rb" with:
      """
      set :environment, :production
      Time.zone = "Pacific Time (US & Canada)"
      activate :blog do |blog|
        blog.sources = "blog/:year-:month-:day-:title.html"
        blog.publish_future_dated = true
      end
      """
    Given the date is 2012-06-18
    And the Server is running at "future-date-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/2012/06/19/future-article.html"
    Then I should see "This is a future-dated article"
    When I go to "/2012/06/19/future-article/example.txt"
    Then I should see "Example Text"