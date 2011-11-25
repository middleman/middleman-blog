Middleman::Extensions.register(:blog, ">= 3.0.0.alpha") do
  require "middleman-blog/extension"
  require "middleman-blog/template"
  
  Middleman::Extensions::Blog
end