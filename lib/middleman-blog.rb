require "middleman-core"

require "middleman-blog/version"
require "middleman-blog/template"
require "middleman-blog/commands/article"

::Middleman::Extensions.register(:blog) do
  if defined?(::Middleman::Extension)
    require "middleman-blog/extension_3_1"
    ::Middleman::BlogExtension
  else
    require "middleman-blog/extension_3_0"
    ::Middleman::Blog
  end
end