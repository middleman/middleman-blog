activate :blog do |blog|
  blog.sources      = ":category/:year-:month-:day-:title.html"
  blog.permalink    = "blog/:year-:month-:day-:title.html"

  blog.custom_collections = {
    :category => {
      :link     => '/categories/:category.html',
      :template => '/category.html'
    }
  }
end
