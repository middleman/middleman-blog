Feature: Derive article date from its source filename
  Scenario: Posts with dates in filenames and optionally frontmatter
    Given the Server is running at "filename-date-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Date: 2011-01-01T00:00:00"
    When I go to "/2011/01/03/filename-and-frontmatter.html"
    Then I should see "Date: 2011-01-03T10:15:00"


