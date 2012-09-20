Feature: Pagination
  Scenario: Index pages are accessible from preview server
    Given the Server is running at "paginate-app"
    When I go to "/2011.html"
    Then I should see "Paginate: true"
    Then I should see "Article Count: 5"
    Then I should see "Page Num: 1"
    Then I should see "Num Pages: 2"
    Then I should see "Per Page: 5"
    Then I should see "Page Start: 1"
    Then I should see "Page End: 5"
    Then I should see "Next Page: '/2011/page/2.html'"
    Then I should see "Prev Page: ''"
    Then I should not see "/2011-01-01-test-article.html"
    Then I should not see "/2011-01-02-test-article.html"
    Then I should see "/2011-01-03-test-article.html"
    Then I should see "/2011-01-04-test-article.html"
    Then I should see "/2011-01-05-test-article.html"
    Then I should see "/2011-02-01-test-article.html"
    Then I should see "/2011-02-02-test-article.html"

    When I go to "/2011/page/2.html"
    Then I should see "Article Count: 2"
    Then I should see "Page Num: 2"
    Then I should see "Page Start: 6"
    Then I should see "Page End: 7"
    Then I should see "Next Page: ''"
    Then I should see "Prev Page: '/2011.html'"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should not see "/2011-01-03-test-article.html"
    Then I should not see "/2011-01-04-test-article.html"
    Then I should not see "/2011-01-05-test-article.html"
    Then I should not see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-02-test-article.html"

    When I go to "/tags/bar.html"
    Then I should see "Paginate: true"
    Then I should see "Article Count: 2"
    Then I should see "Page Num: 1"
    Then I should see "Num Pages: 3"
    Then I should see "Per Page: 2"
    Then I should see "Page Start: 1"
    Then I should see "Page End: 2"
    Then I should see "Next Page: '/tags/bar/page/2.html'"
    Then I should see "Prev Page: ''"
    Then I should see "/2011-02-02-test-article.html"
    Then I should see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-05-test-article.html"
    Then I should not see "/2011-01-04-test-article.html"
    Then I should not see "/2011-01-03-test-article.html"

  Scenario: Index pages are accessible from preview server, with pagination off
    Given a fixture app "paginate-app"
    And app "paginate-app" is using config "paginate-off"
    And the Server is running
    When I go to "/2011.html"
    Then I should see "Paginate: false"
    Then I should see "Article Count: 7"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should see "/2011-01-03-test-article.html"
    Then I should see "/2011-01-04-test-article.html"
    Then I should see "/2011-01-05-test-article.html"
    Then I should see "/2011-02-01-test-article.html"
    Then I should see "/2011-02-02-test-article.html"

    When I go to "/2011/01.html"
    Then I should see "Paginate: false"
    Then I should see "Article Count: 5"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should see "/2011-01-03-test-article.html"
    Then I should see "/2011-01-04-test-article.html"
    Then I should see "/2011-01-05-test-article.html"
    Then I should not see "/2011-02-01-test-article.html"
    Then I should not see "/2011-02-02-test-article.html"

    When I go to "/2011/page/2.html"
    Then I should see "File Not Found"

    When I go to "/tags/foo.html"
    Then I should see "Paginate: false"
    Then I should see "Article Count: 2"
    Then I should not see "/2011-02-02-test-article.html"
    Then I should not see "/2011-02-01-test-article.html"
    Then I should see "/2011-01-02-test-article.html"
    Then I should see "/2011-01-01-test-article.html"

    When I go to "/tags/bar.html"
    Then I should see "Paginate: false"
    Then I should see "Article Count: 2"
    Then I should see "/2011-02-02-test-article.html"
    Then I should see "/2011-02-01-test-article.html"
    Then I should not see "/2011-01-05-test-article.html"
    Then I should not see "/2011-01-04-test-article.html"
    Then I should not see "/2011-01-03-test-article.html"

  Scenario: Index pages are accessible from preview server, with directory_indexes on
    Given a fixture app "paginate-app"
    And app "paginate-app" is using config "directory-indexes"
    And the Server is running
    When I go to "/2011.html"
    Then I should see "File Not Found"

    When I go to "/2011/"
    Then I should see "Next Page: '/2011/page/2/'"
    Then I should not see "/2011-01-03-test-article.html"
    Then I should see "/2011-01-03-test-article/"

    When I go to "/2011/page/2/"
    Then I should see "Prev Page: '/2011/'"

    When I go to "/tags/bar/"
    Then I should see "Next Page: '/tags/bar/page/2/'"

  Scenario: Index pages also get built
    Given a successfully built app at "paginate-app"
    When I cd to "build"
    Then the following files should exist:
    | tags/foo.html        |
    | tags/bar.html        |
    | tags/bar/page/2.html |
    | tags/bar/page/3.html |
    | 2011.html            |
    | 2011/page/2.html     |
    Then the following files should not exist:
    | tags.html     |
    | calendar.html |

    And the file "2011/page/2.html" should contain "Year: '2011'"
    And the file "2011/page/2.html" should contain "Month: ''"
    And the file "2011/page/2.html" should contain "Day: ''"
    And the file "2011/page/2.html" should contain "Article Count: 2"
    And the file "2011/page/2.html" should contain "/2011-01-02-test-article.html"
    And the file "2011/page/2.html" should contain "/2011-01-01-test-article.html"

    And the file "tags/bar/page/2.html" should contain "Tag: bar"
    And the file "tags/bar/page/2.html" should contain "Article Count: 2"
    And the file "tags/bar/page/2.html" should contain "Prev Page: '/tags/bar.html'"
    And the file "tags/bar/page/2.html" should contain "Next Page: '/tags/bar/page/3.html'"
    And the file "tags/bar/page/2.html" should contain "/2011-01-05-test-article.html"
    And the file "tags/bar/page/2.html" should contain "/2011-01-04-test-article.html"

    And the file "tags/bar/page/3.html" should contain "Tag: bar"
    And the file "tags/bar/page/3.html" should contain "Article Count: 1"
    And the file "tags/bar/page/3.html" should contain "Prev Page: '/tags/bar/page/2.html'"
    And the file "tags/bar/page/3.html" should contain "Next Page: ''"
    And the file "tags/bar/page/3.html" should contain "/2011-01-03-test-article.html"

  Scenario: Adding a tag to a post in preview adds a new index page
    Given the Server is running at "paginate-app"
    When I go to "/tags/foo.html"
    Then I should see "/2011-01-01-test-article.html"
    Then I should see "Next Page: ''"

    When I go to "/tags/foo/page/2.html"
    Then I should see "Not Found"

    And the file "source/blog/2011-02-03-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-02-03
      tags: foo
      ---

      Newer Article Content
      """
    When I go to "/tags/foo.html"
    Then I should see "Next Page: '/tags/foo/page/2.html'"
    Then I should see "/2011-02-03-new-article.html"
    Then I should not see "/2011-01-01-test-article.html"

    When I go to "/tags/foo/page/2.html"
    Then I should see "/2011-01-01-test-article.html"
