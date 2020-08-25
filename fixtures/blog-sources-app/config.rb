# frozen_string_literal: true

activate :blog do |blog|
  blog.sources = 'blog/:year-:month-:day-:title.html'
end
