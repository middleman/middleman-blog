activate :blog do |blog|
  blog.sources           = "blog/:year-:month-:day-:title.html"
  blog.permalink         = "blog/:year-:month-:day-:title.html"
  blog.calendar_template = 'calendar.html'
  blog.tag_template      = 'tag.html'
  blog.paginate          = true
  blog.per_page          = 5
end

activate :directory_indexes
