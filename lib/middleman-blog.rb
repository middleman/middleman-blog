require "middleman-core"
require "middleman-more"

require "middleman-blog/version"
require "middleman-blog/template"
require "middleman-blog/commands/article"
  
::Middleman::Extensions.register(:blog, ">= 3.0.0.beta.3") do
  require "middleman-blog/extension"
  ::Middleman::Blog
end
