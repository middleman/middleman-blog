require "middleman-core"

require "middleman-blog/version"
require "middleman-blog/template"
require "middleman-blog/commands/article"

::Middleman::Extensions.register(:blog) do
  require "middleman-blog/extension"
  ::Middleman::BlogExtension
end
