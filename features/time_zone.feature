Feature: Setup time zone
  Scenario: Time.zone can be set through set at config.rb
    Given the Server is running at "time-zone-app"
    When I go to "/blog/2013/06/24/hello.html"
    Then I should see "(GMT+09:00) Tokyo"
