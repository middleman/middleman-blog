Feature: Calendar pages
  Scenario: Calendar pages are accessible from preview server
    Given the Server is running at "calendar-app"
    When I go to "/2011/01/01.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should not see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: '1'"

    When I go to "/2011/01/02.html"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: '2'"

    When I go to "/2011/01.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: ''"

    When I go to "/2011.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: ''"
    Then I should see "Day: ''"

    When I go to "/index.html"
    Then I should see "Year Path: '/2011.html'"
    Then I should see "Month Path: '/2011/01.html'"
    Then I should see "Day Path: '/2011/01/01.html'"

  Scenario: Calendar pages are accessible from preview server with directory_indexes
    Given a fixture app "calendar-app"
    And app "calendar-app" is using config "directory-indexes"
    And the Server is running
    When I go to "/2011.html"
    Then I should see "File Not Found"

    When I go to "/2011/"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-01-new-article/"

    When I go to "/index.html"
    Then I should see "Year Path: '/2011/'"
    Then I should see "Month Path: '/2011/01/'"
    Then I should see "Day Path: '/2011/01/01/'"

  Scenario: Calendar pages also get built
    Given a successfully built app at "calendar-app"
    When I cd to "build"
    Then the following files should exist:
    | 2011.html       |
    | 2011/01.html    |
    | 2011/01/01.html |
    | 2011/01/02.html |

    And the file "2011.html" should contain "/2011-01-01-new-article.html"
    And the file "2011.html" should contain "/2011-01-02-another-article.html"
    And the file "2011.html" should contain "Year: '2011'"
    And the file "2011.html" should contain "Month: ''"
    And the file "2011.html" should contain "Day: ''"

    And the file "2011/01.html" should contain "/2011-01-01-new-article.html"
    And the file "2011/01.html" should contain "/2011-01-02-another-article.html"
    And the file "2011/01.html" should contain "Year: '2011'"
    And the file "2011/01.html" should contain "Month: '1'"
    And the file "2011/01.html" should contain "Day: ''"

    And the file "2011/01/01.html" should contain "/2011-01-01-new-article.html"
    And the file "2011/01/01.html" should not contain "/2011-01-02-another-article.html"
    And the file "2011/01/01.html" should contain "Year: '2011'"
    And the file "2011/01/01.html" should contain "Month: '1'"
    And the file "2011/01/01.html" should contain "Day: '1'"

    And the file "2011/01/02.html" should not contain "/2011-01-01-new-article.html"
    And the file "2011/01/02.html" should contain "/2011-01-02-another-article.html"
    And the file "2011/01/02.html" should contain "Year: '2011'"
    And the file "2011/01/02.html" should contain "Month: '1'"
    And the file "2011/01/02.html" should contain "Day: '2'"

    And the file "index.html" should contain "Year Path: '/2011.html'"
    And the file "index.html" should contain "Month Path: '/2011/01.html'"
    And the file "index.html" should contain "Day Path: '/2011/01/01.html'"

