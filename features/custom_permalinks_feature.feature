Feature: Custom permalinks

  Scenario: Articles list links using custom permalink
    Given the Server is running at "custom-permalinks-app"
    When I go to "/index.html"
    Then I should see "/blog/ruby-on-rails/new-article.html"
    Then I should see "/blog/html5/another-article.html"
    Then I should see "/blog/ruby-on-rails/third-article.html"

  Scenario: Articles can be accessed through permalinks with frontmatter data
    Given the Server is running at "custom-permalinks-app"
    When I go to "/blog/ruby-on-rails/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/blog/html5/another-article.html"
    Then I should see "Another Article Content"

  Scenario: Custom permalinks can be accessed from preview server with directory_indexes
    Given a fixture app "custom-permalinks-app"
    And app "tags-app" is using config "directory-indexes"
    And the Server is running
    When I go to "/blog/ruby-on-rails/new-article.html"
    Then I should see "File Not Found"
    When I go to "/blog/ruby-on-rails/new-article"
    Then I should see "Newer Article Content"
    When I go to "/blog/html5/another-article"
    Then I should see "Another Article Content"

  Scenario: Custom permalinks also get built
    Given a successfully built app at "custom-permalinks-app"
    When I cd to "build"
    Then the following files should exist:
      | blog/ruby-on-rails/new-article.html |
      | blog/html5/another-article.html     |
