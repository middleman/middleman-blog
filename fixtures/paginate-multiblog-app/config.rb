activate :blog do |blog|
  blog.name              = "blog_name_1"
  blog.prefix            = "blog1"
  blog.sources           = ":year-:month-:day-:title.html"
  blog.permalink         = ":year-:month-:day-:title.html"
  blog.calendar_template = 'calendar1.html'
  blog.tag_template      = 'tag1.html'
  blog.paginate          = true
  blog.per_page          = 5
end

activate :blog do |blog2|
  blog2.name              = "blog_name_2"
  blog2.prefix            = "blog2"
  blog2.sources           = ":year-:month-:day-:title.html"
  blog2.permalink         = ":year-:month-:day-:title.html"
  blog2.calendar_template = 'calendar2.html'
  blog2.tag_template      = 'tag2.html'
  blog2.paginate          = true
  blog2.per_page          = 3
end

activate :blog do |blog3|
  blog3.name              = "blog_name_3"
  blog3.prefix            = "blog3"
  blog3.sources           = ":year-:month-:day-:title.html"
  blog3.permalink         = ":year-:month-:day-:title.html"
  blog3.calendar_template = 'calendar3.html'
  blog3.tag_template      = 'tag3.html'
  blog3.paginate          = false
end