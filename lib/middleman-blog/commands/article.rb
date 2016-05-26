require 'middleman-core/cli'
require 'date'
require 'middleman-blog/uri_templates'

module Middleman
  module Cli
    # This class provides an "article" command for the middleman CLI.
    class Article < ::Thor::Group
      include Thor::Actions
      include Blog::UriTemplates

      check_unknown_options!

      # Template files are relative to this file
      # @return [String]
      def self.source_root
        File.dirname(__FILE__)
      end

      argument :title, type: :string

      class_option "date",
        aliases: "-d",
        desc: "The date to create the post with (defaults to now)"
      class_option "lang",
        desc: "Deprecated, use locale"
      class_option "locale",
        aliases: "-l",
        desc: "The locale to create the post with (defaults to I18n.default_locale if avaliable)"
      class_option "blog",
        aliases: "-b",
        desc: "The name of the blog to create the post inside (for multi-blog apps, defaults to the only blog in single-blog apps)"
      def article
        @title = title
        @slug = safe_parameterize(title)
        @date = options[:date] ? ::Time.zone.parse(options[:date]) : Time.zone.now
        @lang = options[:lang] || options[:locale] || (::I18n.default_locale if defined? ::I18n )

        app = ::Middleman::Application.new do
          config[:mode] = :config
          config[:disable_sitemap] = true
          config[:watcher_disable] = true
          config[:exit_before_ready] = true
        end

        blog_inst = if options[:blog]
          app.extensions[:blog].find { |key, instance| instance.options[:name] == options[:blog] }[1]
        else
          app.extensions[:blog].values.first
        end

        unless blog_inst
          msg = "Could not find an active blog instance"
          msg << " named #{options[:blog]}" if options[:blog]
          throw msg
        end

        path_template = blog_inst.data.source_template
        params = date_to_params(@date).merge(lang: @lang.to_s, locale: @locale.to_s, title: @slug)
        article_path = apply_uri_template path_template, params

        template blog_inst.options.new_article_template, File.join(app.source_dir, article_path + blog_inst.options.default_extension)
      end

      protected

      def blog_instance(key)
        return nil unless app.extensions[:blog]
        return app.extensions[:blog][key]
      end

      # Add to CLI
      Base.register(self, 'article', 'article TITLE [options]', 'Create a new blog article')
    end
  end
end
