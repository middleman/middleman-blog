activate :blog do |blog|
  blog.permalink = "{year}.{month}.{day}/{title}"
  blog.sources = "blog/:year-:month-:day-:title.html"
end

activate :directory_indexes
