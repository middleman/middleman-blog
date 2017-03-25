require "middleman-core"
require "middleman-blog/version"

::Middleman::Extensions.register( :blog ) do

    require "middleman-blog/extension"
    require "middleman-blog/commands/article"

    ::Middleman::BlogExtension

end
