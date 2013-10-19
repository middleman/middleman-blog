@three_one

Feature: Tag pages with multiple blogs
  Scenario: Tag pages are accessible from preview server
    Given the Server is running at "tags-multiblog-app"
    When I go to "/blog1/tags/foo1.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    Then I should see "/blog1/2011-01-02-another-article.html"
    Then I should see "Tag1: foo1"
    When I go to "/blog2/tags/foo2.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    Then I should see "/blog2/2011-01-02-another-article.html"
    Then I should see "Tag2: foo2"
    When I go to "/blog1/tags/bar1.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    Then I should not see "/blog1/2011-01-02-another-article.html"
    Then I should see "Tag1: bar1"
    When I go to "/blog2/tags/bar2.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    Then I should not see "/blog2/2011-01-02-another-article.html"
    Then I should see "Tag2: bar2"
    When I go to "/index.html"
    Then I should see "Tag Path1: '/blog1/tags/foox.html'"
    Then I should see "Tag Path2: '/blog2/tags/foox.html'"

  Scenario: Tag pages also get built
    Given a successfully built app at "tags-multiblog-app"
    When I cd to "build"
    Then the following files should exist:
    | blog1/tags/foox.html |
    | blog1/tags/barx.html |
    | blog1/tags/foo1.html |
    | blog1/tags/bar1.html |
    | blog2/tags/foox.html |
    | blog2/tags/barx.html |
    | blog2/tags/foo2.html |
    | blog2/tags/bar2.html |
    Then the following files should not exist:
    | tags1.html |
    | tags2.html |

    And the file "blog1/tags/foox.html" should contain "Tag1: fooX"
    And the file "blog1/tags/foox.html" should contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/tags/foox.html" should contain "/blog1/2011-01-02-another-article.html"
    And the file "blog1/tags/foox.html" should not contain "/blog2/2011-01-01-new-article.html"
    And the file "blog1/tags/foox.html" should not contain "/blog2/2011-01-02-another-article.html"

    And the file "blog1/tags/foo1.html" should contain "Tag1: foo1"
    And the file "blog1/tags/foo1.html" should contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/tags/foo1.html" should contain "/blog1/2011-01-02-another-article.html"

    And the file "blog1/tags/barx.html" should contain "Tag1: barX"
    And the file "blog1/tags/barx.html" should contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/tags/barx.html" should not contain "/blog1/2011-01-02-another-article.html"
    And the file "blog1/tags/barx.html" should not contain "/blog2/2011-01-01-new-article.html"

    And the file "blog1/tags/bar1.html" should contain "Tag1: bar1"
    And the file "blog1/tags/bar1.html" should contain "/blog1/2011-01-01-new-article.html"
    And the file "blog1/tags/bar1.html" should not contain "/blog1/2011-01-02-another-article.html"


    And the file "blog2/tags/foox.html" should contain "Tag2: fooX"
    And the file "blog2/tags/foox.html" should contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/tags/foox.html" should contain "/blog2/2011-01-02-another-article.html"
    And the file "blog2/tags/foox.html" should not contain "/blog1/2011-01-01-new-article.html"
    And the file "blog2/tags/foox.html" should not contain "/blog1/2011-01-02-another-article.html"

    And the file "blog2/tags/foo2.html" should contain "Tag2: foo2"
    And the file "blog2/tags/foo2.html" should contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/tags/foo2.html" should contain "/blog2/2011-01-02-another-article.html"

    And the file "blog2/tags/barx.html" should contain "Tag2: barX"
    And the file "blog2/tags/barx.html" should contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/tags/barx.html" should not contain "/blog2/2011-01-02-another-article.html"
    And the file "blog2/tags/barx.html" should not contain "/blog1/2011-01-01-new-article.html"

    And the file "blog2/tags/bar2.html" should contain "Tag2: bar2"
    And the file "blog2/tags/bar2.html" should contain "/blog2/2011-01-01-new-article.html"
    And the file "blog2/tags/bar2.html" should not contain "/blog2/2011-01-02-another-article.html"

  Scenario: Adding a tag to a post in preview adds a tag page
    Given the Server is running at "tags-multiblog-app"
    When I go to "/blog1/tags/bar1.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    When I go to "/blog1/tags/newtag1.html"
    When I go to "/blog2/tags/bar2.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    When I go to "/blog2/tags/newtag2.html"
    Then I should see "Not Found"
    And the file "source/blog1/2011-01-01-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-01-01
      tags: newtag1, newtagX
      ---

      Newer Article Content
      """
    And the file "source/blog2/2011-01-01-new-article.html.markdown" has the contents
      """
      ---
      title: "Newest Article"
      date: 2011-01-01
      tags: newtag2, newtagX
      ---

      Newer Article Content
      """
    When I go to "/blog1/tags/bar1.html"
    Then I should see "Not Found"
    When I go to "/blog2/tags/bar2.html"
    Then I should see "Not Found"
    When I go to "/blog1/tags/newtag1.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    Then I should not see "/blog2/2011-01-01-new-article.html"
    When I go to "/blog2/tags/newtag2.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    Then I should not see "/blog1/2011-01-01-new-article.html"
    When I go to "/blog1/tags/newtagx.html"
    Then I should see "/blog1/2011-01-01-new-article.html"
    Then I should not see "/blog2/2011-01-01-new-article.html"
    When I go to "/blog2/tags/newtagx.html"
    Then I should see "/blog2/2011-01-01-new-article.html"
    Then I should not see "/blog1/2011-01-01-new-article.html"

  Scenario: Blog data should work when blog name is specified
    Given the Server is running at "tags-multiblog-app"
    When I go to "/blog1/named_blog_tags.html"
    Then I should see "foo1 (2)"
    Then I should see "bar1 (1)"
    Then I should see "fooX (2)"
    Then I should see "barX (1)"
    When I go to "/blog2/named_blog_tags.html"
    Then I should see "foo2 (2)"
    Then I should see "bar2 (1)"
    Then I should see "fooX (2)"
    Then I should see "barX (1)"

  Scenario: Blog data should use blog name in frontmatter
    Given the Server is running at "tags-multiblog-app"
    When I go to "/blog1/frontmatter_blog_tags.html"
    Then I should see "foo1 (2)"
    Then I should see "bar1 (1)"
    Then I should see "fooX (2)"
    Then I should see "barX (1)"
    When I go to "/blog2/frontmatter_blog_tags.html"
    Then I should see "foo2 (2)"
    Then I should see "bar2 (1)"
    Then I should see "fooX (2)"
    Then I should see "barX (1)"
