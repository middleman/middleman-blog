Feature: Blog aliases

  Scenario: Blog articles can have bulk aliases configured

    Given the Server is running at "alias-app"

    When I go to "/2024/03/14/pi-day.html"
    Then I should see "This is a test article for pi day."

    When I go to "/2024-03-14-pi-day.html"
    Then I should see "Redirecting"
    And I should see "/2024/03/14/pi-day.html"

    When I go to "/2024/03-14-pi-day"
    Then I should see "Redirecting"
    And I should see "/2024/03/14/pi-day.html"

  Scenario: Blog aliases work with prefix configuration

    Given the Server is running at "alias-prefix-app"

    When I go to "/blog/2024/01/15/prefix-test.html"
    Then I should see "This article tests prefix functionality"

    When I go to "/blog/2024-01-15-prefix-test.html"
    Then I should see "Redirecting"
    And I should see "/blog/2024/01/15/prefix-test.html"

    When I go to "/blog/archive/2024/prefix-test"
    Then I should see "Redirecting"
    And I should see "/blog/2024/01/15/prefix-test.html"

  Scenario: Empty aliases configuration generates no redirects

    Given the Server is running at "blog-sources-app"

    When I go to "/2011/01/01/new-article.html"
    Then I should see "/2011/01/01/new-article.html"

    When I go to "/2011-01-01-new-article.html"
    Then I should see "Not Found"
