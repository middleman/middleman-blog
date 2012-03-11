Feature: Preview Changes
  In order to run quickly, we should update internal caches on file changes
  
  Scenario: A template changes contents during preview
    Given the Server is running at "preview-app"
    And the file "source/2011/01/01/new-article.html.markdown" has the contents
      """
      --- 
      title: "New Article"
      date: 01/01/2011
      ---

      New Article Content
      """
    When I go to "/2011/01/01/new-article.html"
    Then I should see "New Article Content"
    And I should see "New Article</title>"
    And the file "source/2011/01/01/new-article.html.markdown" has the contents
      """
      --- 
      title: "Newer Article"
      date: 01/01/2011
      ---

      Newer Article Content
      """
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    And I should see "Newer Article</title>"