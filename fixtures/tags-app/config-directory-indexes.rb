require "middleman-blog"
activate :blog do |blog|
  blog.sources      = "blog/:year-:month-:day-:title.html"
  blog.permalink    = "blog/:year-:month-:day-:title.html"
  blog.tag_template = "/tag.html"
end

activate :directory_indexes
