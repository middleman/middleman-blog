Feature: Tag pages
  Scenario: Tag pages are accessible from preview server
    Given the Server is running at "tags-app"
    When I go to "/tags/foo.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Tag: foo"
    When I go to "/tags/bar.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should not see "/2011-01-02-another-article.html"
    Then I should see "Tag: bar"
    
  Scenario: Tag pages also get built
    Given a successfully built app at "tags-app"
    When I cd to "build"
    Then the following files should exist:
    | tags/foo.html |
    | tags/bar.html |
    Then the following files should not exist:
    | tags.html |

    And the file "tags/foo.html" should contain "Tag: foo"
    And the file "tags/foo.html" should contain "/2011-01-01-new-article.html"
    And the file "tags/foo.html" should contain "/2011-01-02-another-article.html"

    And the file "tags/bar.html" should contain "Tag: bar"
    And the file "tags/bar.html" should contain "/2011-01-01-new-article.html"
    And the file "tags/bar.html" should not contain "/2011-01-02-another-article.html"
