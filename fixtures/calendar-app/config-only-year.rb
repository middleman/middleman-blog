Time.zone = "Pacific Time (US & Canada)"

activate :blog do |blog|
  blog.sources              = "blog/:year-:month-:day-:title.html"
  blog.permalink            = "blog/:year-:month-:day-:title.html"
  blog.calendar_template    = 'calendar.html'
  blog.generate_month_pages = false
  blog.generate_day_pages   = false
end
