# frozen_string_literal: true

activate :blog do |blog|
  blog.sources = 'blog/:title.html'
  blog.permalink = 'blog/{title}.html'
end
