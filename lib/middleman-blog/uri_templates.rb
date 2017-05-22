require 'addressable/template'
require 'middleman-core/util'
require 'active_support/inflector'
require 'active_support/inflector/transliterate'

module Middleman

  module Blog

    # Handy methods for dealing with URI templates. Mix into whatever class.
    module UriTemplates

      module_function

      ##
      # Given a URI template string, make an Addressable::Template This supports
      # the legacy middleman-blog/Sinatra style :colon URI templates as well as
      # RFC6570 templates.
      #
      # @param [String] tmpl_src URI template source
      # @return [Addressable::Template] a URI template
      ##
      def uri_template(tmpl_src)
        # Support the RFC6470 templates directly if people use them
        if tmpl_src.include?(':')
          tmpl_src = tmpl_src.gsub(/:([A-Za-z0-9]+)/, '{\1}')
        end

        Addressable::Template.new ::Middleman::Util.normalize_path(tmpl_src)
      end

      ##
      # Apply a URI template with the given data, producing a normalized
      # Middleman path.
      #
      # @param [Addressable::Template] template
      # @param [Hash] data
      # @return [String] normalized path
      ##
      def apply_uri_template(template, data)
        ::Middleman::Util.normalize_path Addressable::URI.unencode(template.expand(data)).to_s
      end

      ##
      # Use a template to extract parameters from a path, and validate some special (date)
      # keys. Returns nil if the special keys don't match.
      #
      # @param [Addressable::Template] template
      # @param [String] path
      ##
      def extract_params(template, path)
        template.extract(path, BlogTemplateProcessor)
      end

      ##
      # Parametrize a string preserving any multi-byte characters
      # Reimplementation of this, preserves un-transliterate-able multibyte chars.
      #
      # @see http://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-parameterize
      ##
      def safe_parameterize(str)
        parameterized_string = ::ActiveSupport::Inflector.transliterate(str.to_s)
        parameterized_string.parameterize
      end

      ##
      # Convert a date into a hash of components to strings suitable for using
      # in a URL template.
      #
      # @param [DateTime] date
      # @return [Hash] parameters
      ##
      def date_to_params(date)
        return {
          year: date.year.to_s,
          month: date.month.to_s.rjust(2, '0'),
          day: date.day.to_s.rjust(2, '0')
        }
      end

      ##
      #
      ##
      def extract_directory_path( article_path )
        uri = Addressable::URI.parse article_path

        # Remove file extension from the article path
        directory_path = uri.path.gsub( uri.extname, '' )
      end

    end

    ##
    # A special template processor that validates date fields and has an extra-
    # permissive default regex.
    #
    # @see https://github.com/sporkmonger/addressable/blob/master/lib/addressable/template.rb#L279
    ##
    class BlogTemplateProcessor
      def self.match(name)
        case name
        when 'year' then '\d{4}'
        when 'month' then '\d{2}'
        when 'day' then '\d{2}'
        else '.*?'
        end
      end
    end

  end

end
