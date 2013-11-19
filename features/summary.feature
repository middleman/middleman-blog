Feature: Article summary generation
  Scenario: Article has no summary separator
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "Summary from article with separator."
    Then I should not see "Extended part from article with separator."
    Then I should see "Summary from article with no separator."
    Then I should not see "Extended part from article with no separator."

  Scenario: Article has custom summary separator
    Given a fixture app "summary-app"
    And a file named "config.rb" with:
      """
      activate :blog do |blog|
        blog.summary_separator = /SPLIT_SUMMARY_BEFORE_THIS/
      end
      """
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "Summary from article with custom separator."
    Then I should not see "Extended part from article with custom separator."
    Then I should see "Extended part from article with separator."

  Scenario: Using a custom summary generator
    Given a fixture app "summary-app"
    And a file named "config.rb" with:
      """
      activate :blog do |blog|
        blog.summary_generator = Proc.new { "This is my summary, and I like it" }
      end
      """
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "This is my summary, and I like it"
    Then I should see "Summary from article"
    Then I should not see "Summary from article with no separator"
    Then I should not see "Extended part from article"

  Scenario: Article has comments in the summary and no summary separator
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "Summary from article with no summary separator and comments in the summary."
    Then I should not see "Extended part from article from article with no summary separator and comments in the summary."

  Scenario: Summary is only limited by a optional summary separator and not by length
    Given a fixture app "summary-app"
    And a file named "config.rb" with:
      """
      activate :blog do |blog|
        blog.summary_length = -1
      end
      """
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "Extended part from article with no separator."
    Then I should not see "Extended part from article with separator."
