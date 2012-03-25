Feature: Nested Layouts Support
  In order to support middleman-core, we should support nested layouts
  
  Scenario: A template using a nested layout
    Given the Server is running at "nested-layouts-app"
    And the file "source/2011/01/01/new-article-title.html.markdown" has the contents
      """
      --- 
      title: "New Article Title"
      date: 01/01/2011
      layout: article
      ---

      New Article Content
      """
    When I go to "/2011/01/01/new-article-title.html"
    Then I should see "New Article Content"
    And I should see "New Article Title</h1>"