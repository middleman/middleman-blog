require "middleman-blog"
activate :blog do |blog|
  blog.prefix       = "blog/"
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":year-:month-:day-:title.html"

  blog.custom_collections = {
    :category => {
      :link     => '/categories/:category.html',
      :template => '/category.html'
    }
  }
end
