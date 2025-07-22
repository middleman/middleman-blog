# frozen_string_literal: true

module Cucumber
  module HTMLFormatter
    class TemplateWriter
      attr_reader :template

      def initialize(template)
        @template = template
      end

      def write_between(from, to)
        from_exists = !from.nil? && template.include?(from)

        after_from = from_exists ? template.split(from)[1] : template
        to.nil? ? after_from : after_from.split(to)[0]
      end
    end
  end
end
