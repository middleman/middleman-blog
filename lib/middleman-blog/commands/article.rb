require 'middleman-core/cli'
require 'date'

module Middleman
  module Cli
    # This class provides an "article" command for the middleman CLI.
    class Article < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :article

      # Template files are relative to this file
      # @return [String]
      def self.source_root
        File.dirname(__FILE__)
      end

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc "article TITLE", "Create a new blog article"
      method_option "date",
        :aliases => "-d",
        :desc => "The date to create the post with (defaults to now)"      
      def article(title)
        shared_instance = ::Middleman::Application.server.inst

        # This only exists when the config.rb sets it!
        if shared_instance.respond_to? :blog
          @title = title
          @slug = title.parameterize
          @date = options[:date] ? Time.zone.parse(options[:date]) : Time.zone.now

          article_path = shared_instance.blog.options.sources.
            sub(':year', @date.year.to_s).
            sub(':month', @date.month.to_s.rjust(2,'0')).
            sub(':day', @date.day.to_s.rjust(2,'0')).
            sub(':title', @slug)

          template "article.tt", File.join(shared_instance.source_dir, article_path + shared_instance.blog.options.default_extension)
        else
          raise Thor::Error.new "You need to activate the blog extension in config.rb before you can create an article"
        end
      end
    end
  end
end

