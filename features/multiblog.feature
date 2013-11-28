@three_one

Feature: Host Multiple Blogs with Middleman 3.1+

  Scenario: Preview
    Given a fixture app "multiblog-app"
    And a file named "config.rb" with:
      """
      activate :blog, :name => "blog_number_1", :prefix => "blog1", :sources => ":year-:month-:day-:title.html", :paginate => true

      activate :blog do |blog|
        blog.name    = "blog_number_2"
        blog.prefix  = "blog2"
        blog.sources = ":year/:month/:day/:title.html"
      end
      """
    Given the Server is running
    When I go to "/blog1/2012/12/12/other-article.html"
    Then I should see "Other Article Content"
    When I go to "/blog2/2011/01/01/new-article.html"
    Then I should see "Newer Article Content"
    When I go to "/index.html"
    Then I should see "blog_number_1 length: 1"
    Then I should see "blog_number_1 title: Other Article"
    Then I should see "blog_number_2 length: 1"
    Then I should see "blog_number_2 title: Newer Article"
    When I go to "/blog1/index.html"
    Then I should see "Paginate: true"

  Scenario: Build
    Given a fixture app "multiblog-app"
    And a file named "config.rb" with:
      """
      activate :blog, :name => "blog_number_1", :prefix => "blog1", :sources => ":year-:month-:day-:title.html"

      activate :blog do |blog|
        blog.name    = "blog_number_2"
        blog.prefix  = "blog2"
        blog.sources = ":year/:month/:day/:title.html"
      end
      """
    Given a successfully built app at "multiblog-app"
    When I cd to "build"
    Then the following files should exist:
    | blog1/2012/12/12/other-article.html |
    | blog2/2011/01/01/new-article.html |

    And the file "blog1/2012/12/12/other-article.html" should contain "Other Article Content"
    And the file "blog2/2011/01/01/new-article.html" should contain "Newer Article Content"
    And the file "index.html" should contain "blog_number_1 length: 1"
    And the file "index.html" should contain "blog_number_1 title: Other Article"
    And the file "index.html" should contain "blog_number_2 length: 1"
    And the file "index.html" should contain "blog_number_2 title: Newer Article"