# frozen_string_literal: true

activate :blog do |blog|
  blog.prefix = 'blog'
  blog.sources = ':year-:month-:day-:title.html'
  blog.permalink = ':year/:month/:day/:title.html'
  blog.aliases = [
    ':year-:month-:day-:title.html',
    'archive/:year/:title'
  ]
end