Feature: Directory Indexes
  Scenario: A template changes contents during preview
    Given the Server is running at "indexes-app"
    When I go to "/2011/01/01/new-article"
    Then I should see "/2011/01/01/new-article/"
    And I should not see "/2011/01/01/new-article.html"