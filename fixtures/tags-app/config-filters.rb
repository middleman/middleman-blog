require 'middleman-blog'

activate :blog do |blog|
  blog.sources      = 'blog/:year-:month-:day-:title.html'
  blog.permalink    = 'blog/:year-:month-:day-:title.html'
  blog.tag_template = '/tag.html'
  blog.filter       = proc { |article| !article.title.start_with?('Another') }
end
