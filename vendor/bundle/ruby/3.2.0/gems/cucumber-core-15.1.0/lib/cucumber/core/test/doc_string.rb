# frozen_string_literal: true

require 'delegate'
module Cucumber
  module Core
    module Test
      # Represents an inline argument in a step. Example:
      #
      #   Given the message
      #     """
      #     I like
      #     Cucumber sandwich
      #     """
      #
      # The text between the pair of <tt>"""</tt> is stored inside a DocString,
      # which is yielded to the StepDefinition block as the last argument.
      #
      # The StepDefinition can then access the String via the #to_s method. In the
      # example above, that would return: <tt>"I like\nCucumber sandwich"</tt>
      #
      # Note how the indentation from the source is stripped away.
      #
      class DocString < SimpleDelegator
        attr_reader :content_type, :content

        def initialize(content, content_type)
          @content = content
          @content_type = content_type
          super @content
        end

        def describe_to(visitor, *args)
          visitor.doc_string(self, *args)
        end

        def data_table?
          false
        end

        def doc_string?
          true
        end

        def map
          raise ArgumentError, 'No block given' unless block_given?

          new_content = yield content
          self.class.new(new_content, content_type)
        end

        def to_step_definition_arg
          self
        end

        def lines_count
          lines.count + 2
        end

        def ==(other)
          return false if other.respond_to?(:content_type) && content_type != other.content_type
          return content == other.to_str if other.respond_to?(:to_str)

          false
        end

        def inspect
          [
            %(#<#{self.class}),
            %(  """#{content_type}),
            %(  #{@content}),
            %(  """>)
          ].join("\n")
        end
      end
    end
  end
end
