Feature: Permalinks can include arbitrary data from frontmatter

  Scenario: Articles list links using permalink with frontmatter data
    Given the Server is running at "permalink-data-app"
    When I go to "/index.html"
    Then I should see "news/a-custom-string-2011-01-01-new-article.html"

  Scenario: Articles can be accessed through permalinks with frontmatter data
    Given the Server is running at "permalink-data-app"
    When I go to "news/a-custom-string-2011-01-01-new-article.html"
    Then I should see "Newer Article Content"
    And I should see "Category: news"
