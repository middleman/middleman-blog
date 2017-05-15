Feature: Article-specific subdirectories

  Scenario: Blog articles can have their own subdirectories for related files

    Given the Server is running at "article-dirs-app"

    When I go to "/blog/2011-01-01-new-article/example.txt"
    Then I should see "Not Found"

    When I go to "/2011/01/01/new-article/example.txt"
    Then I should see "Example Text"

  Scenario: Blog articles with directory_indexes can have their own subdirectories for related files

    Given a fixture app "article-dirs-app"
      And app "article-dirs-app" is using config "directory-indexes"
      And the Server is running

    When I go to "/2011/01/01/new-article"
    Then I should see "Newer Article Content"

    When I go to "/2011-01-01-new-article/example.txt"
    Then I should see "Not Found"

    When I go to "/2011/01/01/new-article/example.txt"
    Then I should see "Example Text"

  Scenario: Blog articles with permalinks containing dots can have their own subdirectories for related files

    Given a fixture app "article-dirs-app"
      And app "article-dirs-app" is using config "permalink-with-dot"
      And the Server is running

    When I go to "/2011.01.01/new-article"
    Then I should see "Newer Article Content"

    When I go to "/2011-01-01-new-article/example.txt"
    Then I should see "Not Found"

    When I go to "/2011.01.01/new-article/example.txt"
    Then I should see "Example Text"
