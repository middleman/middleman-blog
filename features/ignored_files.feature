Feature: Files can be ignored from within blog
  Scenario: A file can be ignored
    Given a fixture app "preview-app"
    And a file named "config.rb" with:
      """
      activate :blog do |blog|
        blog.sources = ":year/:month/:day/:title.html"
      end
      ignore '2011/01/02/newer-article.html'
      """
    # This file would give an error if it weren't ignored
    And a file named "source/2011/01/02/newer-article.html.markdown" with:
      """
      ---
      title: "Newer Article"
      date: 2013-01-15
      ---

      Newer Article Content
      """
    Given the Server is running
    When I go to "/2011/01/01/new-article.html"
    Then I should see "Article"
    When I go to "/2011/01/02/newer-article.html"
    Then I should see "Not Found"
