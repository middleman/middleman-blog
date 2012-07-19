Feature: Article-specific subdirectories
  Scenario: Blog articles can have their own subdirectories for related files
    Given the Server is running at "article-dirs-app"
    When I go to "/blog/2011-01-01-new-article/example.txt"
    Then I should see "Not Found"
    When I go to "/2011/01/01/new-article/example.txt"
    Then I should see "Example Text"
