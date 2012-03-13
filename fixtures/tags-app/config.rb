require "middleman-blog"
activate :blog

set :blog_sources, "blog/:year-:month-:day-:title.html"
set :blog_permalink, "blog/:year-:month-:day-:title.html"
set :blog_tag_template, "/tag.html"
