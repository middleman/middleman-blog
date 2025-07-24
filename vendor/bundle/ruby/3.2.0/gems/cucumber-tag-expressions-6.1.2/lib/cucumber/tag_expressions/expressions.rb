# frozen_string_literal: true

module Cucumber
  module TagExpressions
    # Literal expression node
    class Literal
      def initialize(value)
        @value = value
      end

      def evaluate(variables)
        variables.include?(@value)
      end

      def to_s
        @value
          .gsub(/\\/, '\\\\\\\\')
          .gsub(/\(/, '\\(')
          .gsub(/\)/, '\\)')
          .gsub(/\s/, '\\ ')
      end
    end

    # Not expression node
    class Not
      def initialize(expression)
        @expression = expression
      end

      def evaluate(variables)
        !@expression.evaluate(variables)
      end

      def to_s
        if @expression.is_a?(And) || @expression.is_a?(Or)
          # -- HINT: Binary operations already provide "( ... )"
          "not #{@expression}"
        else
          "not ( #{@expression} )"
        end
      end
    end

    # Or expression node
    class Or
      def initialize(left, right)
        @left = left
        @right = right
      end

      def evaluate(variables)
        @left.evaluate(variables) || @right.evaluate(variables)
      end

      def to_s
        "( #{@left} or #{@right} )"
      end
    end

    # And expression node
    class And
      def initialize(left, right)
        @left = left
        @right = right
      end

      def evaluate(variables)
        @left.evaluate(variables) && @right.evaluate(variables)
      end

      def to_s
        "( #{@left} and #{@right} )"
      end
    end

    class True
      def evaluate(_variables)
        true
      end

      def to_s
        'true'
      end
    end
  end
end
