Feature: Flexible article sources
  Scenario: Blog articles can live under a different structure than their permalink
    Given the Server is running at "blog-sources-app"
    When I go to "/2011/01/01/new-article.html"
    Then I should see "/2011/01/01/new-article.html"
    When I go to "/blog/2001-01-01-new-article.html"
    Then I should see "Not Found"
    When I go to "/"
    Then I should see "/2011/01/01/new-article.html"

  Scenario: Blog articles can omit the day part
    Given the Server is running at "no-day-app"
    When I go to "/2012/08/01/testing.html"
    Then I should see "Testing Article"

  Scenario: Blog article sources can omit the title part
    Given the Server is running at "no-title-app"
    When I go to "/2013/08/07/testing-article.html"
    Then I should see "Testing Article"

  Scenario: Slug can be specified in frontmatter
    Given the Server is running at "no-title-app"
    When I go to "/2013/08/08/slug-from-frontmatter.html"
    Then I should see "Article with slug specified in frontmatter"
    Given the Server is running at "blog-sources-app"
    When I go to "/2013/08/08/slug-from-frontmatter.html"
    Then I should see "Article with slug specified in frontmatter"

  Scenario: There can be subdirectories in the blog sources dir
    Given the Server is running at "blog-sources-subdirs-app"
    When I go to "/blog.html"
    Then I should see "Yet another post"