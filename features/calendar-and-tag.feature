Feature: Calendar and Tag pages
  Scenario: Calendar pages are using the same template
    Given the Server is running at "calendar-and-tag-app"
    When I go to "/2011.html"
    Then I should not see "Tag:"
    Then I should see "Year: '2011'"
    Then I should see "Month: ''"
    Then I should see "Day: ''"

    When I go to "/2011/01.html"
    Then I should not see "Tag:"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: ''"

    When I go to "/2011/01/01.html"
    Then I should not see "Tag:"
    Then I should see "Year: '2011'"
    Then I should see "Month: '1'"
    Then I should see "Day: '1'"

    When I go to "/tags/foo.html"
    Then I should see "Tag: 'foo'"
    Then I should not see "Year:"
    Then I should not see "Month:"
    Then I should not see "Day:"

  Scenario: Calendar pages also get built
    Given a successfully built app at "calendar-and-tag-app"
    When I cd to "build"
    Then the following files should exist:
    | 2011.html       |
    | 2011/01.html    |
    | 2011/01/01.html |
    | tags/foo.html   |

    And the file "2011.html" should not contain "Tag:"
    And the file "2011.html" should contain "Year: '2011'"
    And the file "2011.html" should contain "Month: ''"
    And the file "2011.html" should contain "Day: ''"

    And the file "2011/01.html" should not contain "Tag:'"
    And the file "2011/01.html" should contain "Year: '2011'"
    And the file "2011/01.html" should contain "Month: '1'"
    And the file "2011/01.html" should contain "Day: ''"

    And the file "2011/01/01.html" should not contain "Tag:"
    And the file "2011/01/01.html" should contain "Year: '2011'"
    And the file "2011/01/01.html" should contain "Month: '1'"
    And the file "2011/01/01.html" should contain "Day: '1'"

    And the file "tags/foo.html" should contain "Tag: 'foo'"
    And the file "tags/foo.html" should not contain "Year:"
    And the file "tags/foo.html" should not contain "Month:"
    And the file "tags/foo.html" should not contain "Day:"

