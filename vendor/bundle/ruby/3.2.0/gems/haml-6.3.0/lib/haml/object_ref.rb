# frozen_string_literal: true
module Haml
  module ObjectRef
    class << self
      def parse(args)
        object, prefix = args
        return {} unless object

        suffix =
          if object.respond_to?(:haml_object_ref)
            object.haml_object_ref
          else
            underscore(object.class)
          end
        {
          'class' => [prefix, suffix].compact.join('_'),
          'id'    => [prefix, suffix, object.id || 'new'].compact.join('_'),
        }
      end

      private

      # Haml::Buffer.underscore
      def underscore(camel_cased_word)
        word = camel_cased_word.to_s.dup
        word.gsub!(/::/, '_')
        word.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        word.tr!('-', '_')
        word.downcase!
        word
      end
    end
  end
end
