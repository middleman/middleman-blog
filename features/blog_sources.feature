Feature: Flexible article sources
  Scenario: Blog articles can live under a different structure than their permalink
    Given the Server is running at "blog-sources-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "/2011/01/01/new-article.html"
    When I go to "/blog/2001-01-01-new-article.html"
    Then I should see "Not Found"
    When I go to "/"
    Then I should see "/2011/01/01/new-article.html"
