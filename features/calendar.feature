Feature: Calendar pages
  Scenario: Calendar pages are accessible from preview server
    Given the Server is running at "calendar-app"
    When I go to "/2011.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: ''"
    Then I should see "Day: ''"

    When I go to "/2011/01.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: ''"

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
