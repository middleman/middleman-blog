Time.zone = "Pacific Time (US & Canada)"

activate :blog do |blog|
  blog.name         = "blog_name_1"
  blog.prefix       = "blog1"
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":year-:month-:day-:title.html"
  blog.calendar_template = "calendar1.html"
end

activate :blog do |blog|
  blog.name         = "blog_name_2"
  blog.prefix       = "blog2"
  blog.sources      = ":year-:month-:day-:title.html"
  blog.permalink    = ":year-:month-:day-:title.html"
  blog.calendar_template = "calendar2.html"
end