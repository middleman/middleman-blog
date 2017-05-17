require 'middleman-core/cli'
require 'date'
require 'middleman-blog/uri_templates'

module Middleman

  module Cli

    ##
    # This class provides an "article" command for the middleman CLI.
    #
    # @usage bundle exec middleman article --help
    # @usage bundle exec middleman article "Article Title"
    # @usage bundle exec middleman article "Article Title" -t "test,test1" -c "<b>String</b>" -d 2017-03-25 -l fr-be -b blog_fr-be -s -e
    #
    # @see   https://middlemanapp.com/basics/blogging/#generating-articles
    #
    # @todo Tags should be removed from the template if they are not required
    ##
    class Article < ::Thor::Group

      include Thor::Actions
      include Blog::UriTemplates

      check_unknown_options!

      # Template files are relative to this file
      # @return [String]
      def self.source_root
        File.dirname( __FILE__ )
      end

      argument :title, type: :string

      class_option "blog",
        aliases: "-b",
        desc:    "The name of the blog to create the post inside (for multi-blog apps, defaults to the only blog in single-blog apps)"

      class_option "content",
        aliases: "-c",
        desc: "Content of the post"

      class_option "date",
        aliases: "-d",
        desc:    "The date to create the post with (defaults to now)"

      class_option "locale",
        aliases: "-l",
        desc:    "The locale to create the post with (defaults to I18n.default_locale if available)"

      class_option "edit",
        aliases: "-e",
        desc:    "Edit the newly created blog post",
        default: false,
        type:    :boolean

      class_option "subdirectory",
        aliases: "-s",
        desc:    "Generate an article subdirectory (for directory indexes, defaults to false)",
        default: false,
        type:    :boolean

      class_option "tags",
        aliases: "-t",
        desc: "A list of comma-separated tags for the post"

      def article

        @content = options[:content] || ""
        @date    = options[ :date ] ? ::Time.zone.parse( options[ :date ] ) : Time.zone.now
        @locale  = options[ :locale ] || ( ::I18n.default_locale if defined? ::I18n )
        @slug    = safe_parameterize( title )
        @tags    = options[:tags] && options[:tags].split(/\s*,\s*/) || []
        @title   = title

        app = ::Middleman::Application.new do
          config[ :mode ]              = :config
          config[ :disable_sitemap ]   = true
          config[ :watcher_disable ]   = true
          config[ :exit_before_ready ] = true
        end

        blog_inst = if options[ :blog ]
          app.extensions[ :blog ].find { | key, instance | instance.options[ :name ] == options[ :blog ] }[ 1 ]
        else
          app.extensions[ :blog ].values.first
        end

        unless blog_inst
          msg = "Could not find an active blog instance"
          msg << " named #{ options[ :blog ] }" if options[ :blog ]
          throw msg
        end

        path_template         = blog_inst.data.source_template
        params                = date_to_params( @date ).merge( locale: @locale.to_s, title: @slug )
        article_path          = apply_uri_template path_template, params
        absolute_article_path = File.join( app.source_dir, article_path + blog_inst.options.default_extension )

        template blog_inst.options.new_article_template, absolute_article_path

        # Edit option process
        if options[ :edit ]

          editor = ENV.fetch( 'MM_EDITOR', ENV.fetch( 'EDITOR', nil ) )

          if editor
            system( "#{ editor } #{ absolute_article_path }" )
          else
            throw "Could not find a suitable editor. Try setting the environment variable MM_EDITOR."
          end

        end

        # Subdirectory option process
        if options[ :subdirectory ]
          empty_directory extract_directory_path( File.join( app.source_dir, article_path ) )
        end

      end

      protected

      def blog_instance( key )
        return nil unless app.extensions[ :blog ]
        return app.extensions[ :blog ][ key ]
      end

      # Add to CLI
      Base.register( self, 'article', 'article TITLE [options]', 'Create a new blog article' )

    end

  end

end
