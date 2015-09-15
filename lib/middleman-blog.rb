require "middleman-core"
require "middleman-blog/version"

::Middleman::Extensions.register(:blog) do
  require "middleman-blog/extension"
  ::Middleman::BlogExtension
end
