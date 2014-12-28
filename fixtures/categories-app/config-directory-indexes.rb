require "middleman-blog"
activate :blog do |blog|
  blog.sources      = "blog/:year-:month-:day-:title.html"
  blog.permalink    = "blog/:year-:month-:day-:title.html"
  blog.category_template = "/category.html"
  blog.paginate = true
  blog.per_page = 2
end

activate :directory_indexes
