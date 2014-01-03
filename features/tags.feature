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
    When I go to "/tags/120.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Tag: 120"
    When I go to "/index.html"
    Then I should see "Tag Path: '/tags/foo.html'"

  Scenario: Tag pages are accessible from preview server with directory_indexes
    Given a fixture app "tags-app"
    And app "tags-app" is using config "directory-indexes"
    And the Server is running
    When I go to "/tags/foo.html"
    Then I should see "File Not Found"
    When I go to "/tags/foo/"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-01-new-article/"
    When I go to "/index.html"
    Then I should see "Tag Path: '/tags/foo/'"

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

  Scenario: Adding a tag to a post in preview adds a tag page
    Given the Server is running at "tags-app"
    When I go to "/tags/bar.html"
    Then I should see "/2011-01-01-new-article.html"
    When I go to "/tags/newtag.html"
    Then I should see "Not Found"
    And the file "source/blog/2011-01-01-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-01-01
      tags: newtag
      ---

      Newer Article Content
      """
    When I go to "/tags/bar.html"
    Then I should see "Not Found"
    When I go to "/tags/newtag.html"
    Then I should see "/2011-01-01-new-article.html"

  Scenario: Adding a non-ASCII tag to a post in preview adds a tag page
    Given the Server is running at "tags-app"
    When I go to "/tags/☆☆☆.html"
    Then I should see "Not Found"
    And the file "source/blog/2011-01-01-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-01-01
      tags: ☆☆☆
      ---

      Newer Article Content
      """
    When I go to "/tags/☆☆☆.html"
    Then I should see "/2011-01-01-new-article.html"
