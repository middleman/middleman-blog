require "middleman-blog"
activate :blog do |blog|
  blog.sources      = "blog/:year-:month-:day-:title.html"
  blog.permalink    = "blog/:category/:title.html"
end

require "middleman-more"
activate :directory_indexes
