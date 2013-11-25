require "middleman-blog"
activate :blog do |blog|
  blog.sources      = ":category/:year-:month-:day-:title.html"
  blog.permalink    = ":category/:custom-:year-:month-:day-:title.html"
end
