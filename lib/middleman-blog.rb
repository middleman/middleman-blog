require "middleman-core"

::Middleman::Extensions.register(:blog, ">= 3.0.0.beta.2") do
  require "middleman-blog/extension"
  require "middleman-blog/template"
  
  ::Middleman::Extensions::Blog
end