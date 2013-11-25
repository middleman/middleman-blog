Feature: New article CLI command
 Scenario: Create a new blog article with the CLI
   Given a fixture app "blog-sources-app"
   And I run `middleman article "My New Article" --date 2012-03-17`
   Then the exit status should be 0
   Then the following files should exist:
     | source/blog/2012-03-17-my-new-article.html.markdown |
   And the file "source/blog/2012-03-17-my-new-article.html.markdown" should contain "tags"

 Scenario: Create a new blog article with the CLI using a custom template
   Given a fixture app "custom-article-template-app"
   And I run `middleman article "My New Article" --date 2012-03-17`
   Then the exit status should be 0
   Then the following files should exist:
     | source/2012-03-17-my-new-article.html.markdown |
   And the file "source/2012-03-17-my-new-article.html.markdown" should contain "From a template!"