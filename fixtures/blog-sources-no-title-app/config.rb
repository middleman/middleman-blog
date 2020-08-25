# frozen_string_literal: true

activate :blog do |blog|
  blog.sources = ':year-:month-:day.html'
end
