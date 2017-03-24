Feature: Internationalized articles
  Scenario: Article has lang in frontmatter
    Given the Server is running at "language-app"
    When I go to "/index.html"
    Then I should see "Some text in English. All is OK."
    Then I should not see "Некоторый текст на русском языке. Всё отлично."
    When I go to "/ru/index.html"
    Then I should see "Некоторый текст на русском языке. Всё отлично."
    Then I should not see "Some text in English. All is OK."

  Scenario: Article has lang in path
    Given a fixture app "language-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      activate :blog, prefix: ":lang"
      """
    Given the Server is running at "language-app"
    When I go to "/index.html"
    Then I should see "Some text in English. All is OK."
    Then I should not see "Некоторый текст на русском языке. Всё отлично."
    When I go to "/ru/index.html"
    Then I should see "Некоторый текст на русском языке. Всё отлично."
    Then I should not see "Some text in English. All is OK."

  Scenario: Article has lang in source path
    Given a fixture app "lang-path-app"
    Given the Server is running at "lang-path-app"
    When I go to "/en/a-humble-test.html"
    Then I should see "English!"
    When I go to "/ru/a-humble-test.html"
    Then I should see "Russian!"

  Scenario: Custom locales in articles
    Given a fixture app "language-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      activate :blog, preserve_locale: true
      """
    Given the Server is running at "language-app"
    When I go to "/index.html"
    Then I should see "Some text in English. All is OK."
    When I go to "/ru/index.html"
    Then I should see "Некоторый текст на русском языке. Всё отлично."

  Scenario: Layout's locale match article's locale on article page
    Given a fixture app "language-app"
    Given the Server is running at "language-app"
    When I go to "/2013/09/07/english-article-with-lang-in-frontmatter.html"
    Then I should see "Language: en"
    Then I should see "Hello, world!"
    Then I should not see "Язык: ru"
    Then I should not see "Привет, мир!"
    When I go to "/2013/09/07/russian-article-with-lang-in-frontmatter.html"
    Then I should see "Язык: ru"
    Then I should see "Привет, мир!"
    Then I should not see "Language: en"
    Then I should not see "Hello, world!"

  Scenario: Custom locales on article pages
    Given a fixture app "language-app"
    And a file named "config.rb" with:
      """
      activate :i18n
      activate :blog, preserve_locale: true
      """
    Given the Server is running at "language-app"
    When I go to "/2013/09/07/english-article-with-lang-in-frontmatter.html"
    Then I should see "Language: en"
    Then I should see "Hello, world!"
    Then I should not see "Язык: ru"
    Then I should not see "Привет, мир!"
    When I go to "/2013/09/07/russian-article-with-lang-in-frontmatter.html"
    Then I should see "Language: en"
    Then I should see "Hello, world!"
    Then I should not see "Язык: ru"
    Then I should not see "Привет, мир!"

  Scenario: Next and previous local article
    Given a fixture app "language-app"
    When I go to "/2013/09/07/english-article-with-lang-in-frontmatter.html"
    Then I should see "Next: /2013/09/09/next-english-article.html"
    Then I should not see "Next: /2013/09/08/next-russian-article.html"
    Then I should see "Previous: /2013/09/05/previous-english-article.html"
    Then I should not see "Previous: /2013/09/06/previous-russian-article.html"
