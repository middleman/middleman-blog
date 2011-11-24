Middleman::Extensions.register(:blog, ">= 3.0.0.alpha") do |version|
  require "middleman-blog"
  Middleman::Extensions::Blog
end