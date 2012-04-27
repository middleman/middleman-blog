activate :blog do |blog|
  blog.sources = ":year/:month/:day/:title.html"
end

page "/feed.xml", :layout => false

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :cache_buster
end