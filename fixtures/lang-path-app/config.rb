activate :i18n

activate :blog do |blog|
  blog.sources = "blog/{year}-{month}-{day}-{title}.{lang}.html"
  blog.permalink = "{lang}/{title}.html"
end
