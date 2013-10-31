require "middleman-blog"
activate :blog do |blog|
  blog.sources      = "blog/:year-:month-:day-:title.html"
  blog.permalink    = "blog/:category/:title.html"
end

activate :directory_indexes
