Feature: Article summary generation
  Scenario: Article has no summary separator
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see:
      """
      <p>Summary from article with separator.
      </p>
      """
    Then I should not see "Extended part from article with separator."
    Then I should see "<p>Summary from article with no separator.</p>"
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
    Then I should see:
      """
      <p>Summary from article with custom separator.
      </p>
      """
    Then I should not see "Extended part from article with custom separator."
    Then I should see "Extended part from article with separator."

  Scenario: Article has custom summary separator that's an HTML comment
    Given a fixture app "summary-app"
    And a file named "config.rb" with:
      """
      activate :blog do |blog|
        blog.summary_separator = /<!--more-->/
      end
      """
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see:
      """
      <p>Summary from article with HTML comment separator.
      </p>
      """
    Then I should not see "Extended part from article with HTML comment separator."
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
    Then I should not see "Summary from article"
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

  Scenario: Summary limited by length only
    Given a fixture app "summary-app"
    And a file named "config.rb" with:
      """
      activate :blog
      """
    And a file named "source/index.html.erb" with:
      """
      <% @i = 0 %>
      <% blog.articles.each do |article| %>
        <article>
          <%= article.summary(7, (@i += 1).to_s) %>
        </article>
      <% end %>
      """
    Given the Server is running at "summary-app"
    When I go to "/index.html"
    Then I should see "Summary1"
    Then I should see "Summary2"
    Then I should see "Summary3"
    # it has a custom separator, which overrides explicit length, so we show up to the separator
    Then I should see "Summary from article with separator."
    Then I should see "Summary5"
