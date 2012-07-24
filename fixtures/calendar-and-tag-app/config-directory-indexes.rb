activate :blog do |blog|
  blog.sources           = "blog/:year-:month-:day-:title.html"
  blog.permalink         = "blog/:year-:month-:day-:title.html"
  blog.calendar_template = 'calendar.html'
end

require "middleman-more"
activate :directory_indexes
