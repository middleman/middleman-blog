Feature: Custom collection pages

  Scenario: Collection pages are accessible from the preview server
    Given the Server is running at "custom-collections-app"
    When I go to "/categories/ruby-on-rails.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should not see "/2011-01-02-another-article.html"
    When I go to "/categories/html5.html"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    When I go to "/index.html"
    Then I should see "Category Path: '/categories/ruby-on-rails.html'"
    When I go to "/categories/.html"
    Then I should see "Not Found"

  Scenario: Collection pages are accessbile from preview server with directory_indexes
    Given a fixture app "custom-collections-app"
    And app "custom-collections-app" is using config "directory-indexes"
    And the Server is running
    When I go to "/categories/ruby-on-rails.html"
    Then I should see "File Not Found"
    When I go to "/categories/ruby-on-rails"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-01-new-article"
    When I go to "/index.html"
    Then I should see "Category Path: '/categories/ruby-on-rails/'"

  Scenario: Collection pages also get built
    Given a successfully built app at "custom-collections-app"
    When I cd to "build"
    Then the following files should exist:
    | categories/ruby-on-rails.html |
    | categories/html5.html |
    Then the following files should not exist:
    | categories.html |

    And the file "categories/ruby-on-rails.html" should contain "Category: ruby-on-rails"
    And the file "categories/ruby-on-rails.html" should contain "/2011-01-01-new-article.html"
    And the file "categories/ruby-on-rails.html" should not contain "/2011-01-02-another-article.html"

    And the file "categories/html5.html" should contain "Category: html5"
    And the file "categories/html5.html" should not contain "/2011-01-01-new-article.html"
    And the file "categories/html5.html" should contain "/2011-01-02-another-article.html"

  Scenario: Adding a post to a collection adds a collection page
    Given the Server is running at "custom-collections-app"
    When I go to "/categories/ruby-on-rails.html"
    Then I should see "/2011-01-01-new-article.html"
    When I go to "/categories/newcat.html"
    Then I should see "Not Found"
    And the file "source/blog/2011-01-01-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-01-01
      category: newcat
      ---

      Newer Article Content
      """
    When I go to "/categories/bar.html"
    Then I should see "Not Found"
    When I go to "/categories/newcat.html"
    Then I should see "/2011-01-01-new-article.html"

  Scenario: Collection pages are properly nested when using a blog prefix
    Given a fixture app "custom-collections-app"
    And app "custom-collections-app" is using config "blog-prefix"
    And the Server is running
    When I go to "/blog/categories/ruby-on-rails.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should not see "/2011-01-02-another-article.html"

  Scenario: Collection property can use source path data
    Given the Server is running at "custom-collections-sources-app"
    When I go to "/categories/news.html"
    Then I should see "/2011-01-01-new-article.html"
    Then I should not see "/2011-01-02-another-article.html"
    When I go to "/categories/articles.html"
    Then I should not see "/2011-01-01-new-article.html"
    Then I should see "/2011-01-02-another-article.html"
    When I go to "/index.html"
    Then I should see "Category Path: '/categories/articles.html'"
