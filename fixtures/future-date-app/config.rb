Time.zone = "Pacific Time (US & Canada)"

activate :blog do |blog|
  blog.sources = "blog/:year-:month-:day-:title.html"
end
