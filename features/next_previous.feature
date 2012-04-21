Feature: Next and previous article
  
  Scenario: Articles know their next and previous article
    Given the Server is running at "calendar-app"
    When I go to "/blog/2011-01-01-new-article.html"
    Then I should see "Next: /blog/2011-01-02-another-article.html"
    When I go to "/blog/2011-01-02-another-article.html"
    Then I should see "Previous: /blog/2011-01-01-new-article.html"
