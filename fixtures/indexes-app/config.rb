activate :blog do |blog|
  blog.sources = ":year/:month/:day/:title.html"
end

activate :directory_indexes