require "middleman-core"

require "middleman-blog/template"

::Middleman::Extensions.register(:blog, ">= 3.0.0.beta.2") do
  require "middleman-blog/extension"
  ::Middleman::Extensions::Blog
end
