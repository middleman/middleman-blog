activate :blog do |blog|
  blog.sources = "blog/:title.html"
  blog.permalink = "blog/{title}"
end
