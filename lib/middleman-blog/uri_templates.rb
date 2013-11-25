require 'addressable/template'

module Middleman
  module Blog
    # Handy methods for dealing with URI templates. Mix into whatever class.
    module UriTemplates

      module_function

      # Given a URI template string, make an Addressable::Template
      # This supports the legacy middleman-blog/Sinatra style :colon
      # URI templates as well as RFC6470 templates.
      #
      # @param [String] URI template source
      # @return [Addressable::Template] a URI template
      def uri_template(tmpl_src)
        # Support the RFC6470 templates directly if people use them
        if tmpl_src.include?(':')
          tmpl_src = tmpl_src.gsub(/:([A-Za-z0-9]+)/, '{\1}')
        end

        Addressable::Template.new ::Middleman::Util.normalize_path(tmpl_src)
      end

      # Apply a URI template with the given data, producing a normalized
      # Middleman path.
      #
      # @param [Addressable::Template] template
      # @param [Hash] data
      # @return [String] normalized path
      def apply_uri_template(template, data)
        ::Middleman::Util.normalize_path Addressable::URI.unencode(template.expand(data)).to_s
      end

      # Parameterize a string only if it does not contain UTF-8 characters
      def safe_parameterize(str)
        if str.chars.all? { |c| c.bytes.count == 1 }
          str.parameterize
        else
          # At least change spaces to dashes
          str.gsub(/\s+/, '-')
        end
      end

      # Convert a date into a hash of components to strings
      # suitable for using in a URL template.
      # @param [DateTime] date
      # @return [Hash] parameters
      def date_to_params(date)
        return {
          year: date.year.to_s,
          month: date.month.to_s.rjust(2,'0'),
          day: date.day.to_s.rjust(2,'0')
        }
      end
    end
  end
end
