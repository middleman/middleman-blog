# frozen_string_literal: true

activate :blog do |blog|
  blog.sources = ':year/:month/:day/:title.html'
end

activate :directory_indexes
