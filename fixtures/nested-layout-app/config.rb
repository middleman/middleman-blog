activate :blog do |blog|
  blog.layout  = "article_layout"
  blog.sources = "blog/:year-:month-:day-:title.html"
end
