@three_one
Feature: Use custom collections with multiple blogs

  Scenario: Custom collection pages are accessible from preview server
    Given the Server is running at "custom-collections-multiblog-app"
    When I go to "/blog1/categories/ruby-on-rails.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    Then I should not see "/blog1/2011-01-02-another-article.html"
    Then I should see "Category1: ruby-on-rails"
    When I go to "/blog2/categories/javascript.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    Then I should not see "/blog2/2011-01-02-another-article.html"
    Then I should see "Category2: javascript"
    When I go to "/blog1/categories/html5.html"
    Then I should not see "/blog1/2011-01-01-new-article.html"
    Then I should see "/blog1/2011-01-02-another-article.html"
    Then I should see "Category1: html5"
    When I go to "/blog2/categories/html5.html"
    Then I should not see "/blog2/2011-01-01-new-article.html"
    Then I should see "/blog2/2011-01-02-another-article.html"
    Then I should not see "/blog1/2011-01-02-another-article.html"
    Then I should see "Category2: html5"
    When I go to "/index.html"
    Then I should see "Category Path1: '/blog1/categories/ruby-on-rails.html'"
    Then I should see "Category Path2: '/blog2/categories/javascript.html'"

  Scenario: Custom pages also get built
    Given a successfully built app at "custom-collections-multiblog-app"
    When I cd to "build"
    Then the following files should exist:
    | blog1/categories/ruby-on-rails.html |
    | blog1/categories/html5.html         |
    | blog2/categories/javascript.html    |
    | blog2/categories/html5.html          |
    Then the following files should not exist:
    | category1.html |
    | category2.html |

    And the file "blog1/categories/ruby-on-rails.html" should contain "Category1: ruby-on-rails"
    And the file "blog1/categories/ruby-on-rails.html" should contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/categories/ruby-on-rails.html" should not contain "/blog1/2011-01-02-another-article.html"
    And the file "blog1/categories/ruby-on-rails.html" should not contain "/blog2/2011-01-01-new-article.html"
    And the file "blog1/categories/ruby-on-rails.html" should not contain "/blog2/2011-01-02-another-article.html"

    And the file "blog1/categories/html5.html" should contain "Category1: html5"
    And the file "blog1/categories/html5.html" should not contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/categories/html5.html" should contain "/blog1/2011-01-02-another-article.html"

    And the file "blog2/categories/javascript.html" should contain "Category2: javascript"
    And the file "blog2/categories/javascript.html" should contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/categories/javascript.html" should not contain "/blog2/2011-01-02-another-article.html"
    And the file "blog2/categories/javascript.html" should not contain "/blog1/2011-01-01-new-article.html"
    And the file "blog2/categories/javascript.html" should not contain "/blog1/2011-01-02-another-article.html"

    And the file "blog2/categories/html5.html" should contain "Category2: html5"
    And the file "blog2/categories/html5.html" should not contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/categories/html5.html" should contain "/blog2/2011-01-02-another-article.html"
    And the file "blog2/categories/html5.html" should not contain "/blog1/2011-01-02-another-article.html"
