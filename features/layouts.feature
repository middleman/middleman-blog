Feature: Layouts
  Background:
    Given the Server is running at "layouts-app"
  Scenario: The layout of a blog entry can be set in its front matter.
    When I go to "/2011/01/01/first-article.html"
    Then I should see "First Alternative Layout"
    And I should see "First Article"
    When I go to "/2011/01/01/second-article.html"
    Then I should see "Second Alternative Layout"
    And I should see "Second Article"
    When I go to "/2011/01/01/third-article.html"
    Then I should see "Third Alternative Layout"
    And I should see "Third Article"
  Scenario: The default blog layout is used if none is set in front matter.
    When I go to "/2011/01/02/article-in-normal-layout.html"
    Then I should see "Default Layout"
    And I should see "New Article"
  Scenario: Do not use a layout for the article if set to false in front matter.
    When I go to "/2011/01/03/article-without-layout.html"
    Then I should not see "Default Layout"
    And I should see "Article Content"
