Feature: Blog aliases

  Scenario: Blog articles can have bulk aliases configured

    Given the Server is running at "alias-app"

    When I go to "/2024/03/14/pi-day.html"
    Then I should see "This is a test article for pi day."

    When I go to "/2024-03-14-pi-day.html"
    Then I should see "Redirecting"
    And I should see "2024/03/14/pi-day.html"

    When I go to "/2024/03-14-pi-day"
    Then I should see "Redirecting"
    And I should see "2024/03/14/pi-day.html"