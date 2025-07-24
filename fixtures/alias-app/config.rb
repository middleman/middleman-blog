# frozen_string_literal: true

activate :blog do |blog|
  blog.permalink = ':year/:month/:day/:title.html'
  blog.aliases = [
    ':year-:month-:day-:title.html',
    ':year/:month-:day-:title'
  ]
end