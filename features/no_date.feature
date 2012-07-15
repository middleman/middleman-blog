Feature: Flexible article sources
  Scenario: Blog sources may not include the date in the filename
    Given the Server is running at "no-date-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "/2011/01/01/new-article.html"
    When I go to "/blog/new-article.html"
    Then I should see "Not Found"
    When I go to "/"
    Then I should see "/2011/01/01/new-article.html"
