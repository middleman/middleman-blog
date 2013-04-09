activate :blog do |blog|
  blog.name         = "blog_name_1"
  blog.prefix       = "blog1"
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":year-:month-:day-:title.html"
  blog.tag_template = "tag1.html"
end

activate :blog do |blog|
  blog.name         = "blog_name_2"
  blog.prefix       = "blog2"
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":year-:month-:day-:title.html"
  blog.tag_template = "tag2.html"
end