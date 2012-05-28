activate :blog do |blog|
  blog.sources = ":year/:month/:day/:title.html"
end

require "middleman-more"
activate :directory_indexes