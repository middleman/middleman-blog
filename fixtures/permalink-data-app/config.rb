require "middleman-blog"
activate :blog do |blog|
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":custom-:year-:month-:day-:title.html"
end
