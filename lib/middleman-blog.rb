require "middleman-core"

require "middleman-blog/version"

begin
  require "middleman-blog/template"
rescue LoadError
  # v4
end

require "middleman-blog/commands/article"

::Middleman::Extensions.register(:blog) do
  require "middleman-blog/extension"
  ::Middleman::BlogExtension
end
