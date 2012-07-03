Feature: Builder
  In order to output static html and css for delivery

  Scenario: Build with nested layout
    Given a fixture app "nested-layout-app"
    When I run `middleman build --debug`
    Then was successfully built
