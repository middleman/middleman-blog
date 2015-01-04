activate :blog do |blog|
  blog.sources            = "blog/:year-:month-:day-:title.html"
  blog.permalink          = "blog/:year-:month-:day-:title.html"
  blog.tag_template       = "/tag.html"
  blog.generate_tag_pages = false
end
