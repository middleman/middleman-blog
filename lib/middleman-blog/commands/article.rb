require 'middleman-core/cli'
require 'date'
require 'middleman-blog/uri_templates'

module Middleman
  module Cli
    # This class provides an "article" command for the middleman CLI.
    class Article < Thor
      include Thor::Actions
      include Blog::UriTemplates

      check_unknown_options!

      namespace :article

      def self.source_root
        ENV['MM_ROOT']
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc "article TITLE", "Create a new blog article"
      method_option "date",
        aliases: "-d",
        desc: "The date to create the post with (defaults to now)"
      method_option "lang",
        aliases: "-l",
        desc: "The language to create the post with (defaults to I18n.default_locale if avaliable)"
      method_option "blog",
        aliases: "-b",
        desc: "The name of the blog to create the post inside (for multi-blog apps, defaults to the only blog in single-blog apps)"
      def article(title)
        shared_instance = ::Middleman::Application.server.inst

        # This only exists when the config.rb sets it!
        if shared_instance.respond_to? :blog
          @title = title
          @slug = safe_parameterize(title)
          @date = options[:date] ? Time.zone.parse(options[:date]) : Time.zone.now
          @lang = options[:lang] || ( I18n.default_locale if defined? I18n )

          blog_inst = shared_instance.blog(options[:blog])

          path_template = blog_inst.source_template
          params = date_to_params(@date).merge(lang: @lang.to_s, title: @slug)
          article_path = apply_uri_template path_template, params

          template blog_inst.options.new_article_template, File.join(shared_instance.source_dir, article_path + blog_inst.options.default_extension)
        else
          raise Thor::Error.new "You need to activate the blog extension in config.rb before you can create an article"
        end
      end
    end
  end
end
