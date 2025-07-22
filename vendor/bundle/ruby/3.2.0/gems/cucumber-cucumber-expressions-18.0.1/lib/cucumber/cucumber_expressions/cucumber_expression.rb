# frozen_string_literal: true

require 'cucumber/cucumber_expressions/argument'
require 'cucumber/cucumber_expressions/tree_regexp'
require 'cucumber/cucumber_expressions/errors'
require 'cucumber/cucumber_expressions/cucumber_expression_parser'

module Cucumber
  module CucumberExpressions
    class CucumberExpression
      ESCAPE_PATTERN = /([\\^\[({$.|?*+})\]])/.freeze

      def initialize(expression, parameter_type_registry)
        @expression = expression
        @parameter_type_registry = parameter_type_registry
        @parameter_types = []
        parser = CucumberExpressionParser.new
        ast = parser.parse(expression)
        pattern = rewrite_to_regex(ast)
        @tree_regexp = TreeRegexp.new(pattern)
      end

      def match(text)
        Argument.build(@tree_regexp, text, @parameter_types)
      end

      def source
        @expression
      end

      def regexp
        @tree_regexp.regexp
      end

      def to_s
        source.inspect
      end

      private

      def rewrite_to_regex(node)
        case node.type
        when NodeType::TEXT
          return escape_regex(node.text)
        when NodeType::OPTIONAL
          return rewrite_optional(node)
        when NodeType::ALTERNATION
          return rewrite_alternation(node)
        when NodeType::ALTERNATIVE
          return rewrite_alternative(node)
        when NodeType::PARAMETER
          return rewrite_parameter(node)
        when NodeType::EXPRESSION
          return rewrite_expression(node)
        else
          # Can't happen as long as the switch case is exhaustive
          raise "#{node.type}"
        end
      end

      def escape_regex(expression)
        expression.gsub(ESCAPE_PATTERN, '\\\\\1')
      end

      def rewrite_optional(node)
        assert_no_parameters(node) { |ast_node| raise ParameterIsNotAllowedInOptional.new(ast_node, @expression) }
        assert_no_optionals(node) { |ast_node| raise OptionalIsNotAllowedInOptional.new(ast_node, @expression) }
        assert_not_empty(node) { |ast_node| raise OptionalMayNotBeEmpty.new(ast_node, @expression) }
        regex = node.nodes.map { |n| rewrite_to_regex(n) }.join('')
        "(?:#{regex})?"
      end

      def rewrite_alternation(node)
        # Make sure the alternative parts aren't empty and don't contain parameter types
        node.nodes.each { |alternative|
          raise AlternativeMayNotBeEmpty.new(alternative, @expression) if alternative.nodes.length == 0

          assert_not_empty(alternative) { |ast_node| raise AlternativeMayNotExclusivelyContainOptionals.new(ast_node, @expression) }
        }
        regex = node.nodes.map { |n| rewrite_to_regex(n) }.join('|')
        "(?:#{regex})"
      end

      def rewrite_alternative(node)
        node.nodes.map { |last_node| rewrite_to_regex(last_node) }.join('')
      end

      def rewrite_parameter(node)
        name = node.text
        parameter_type = @parameter_type_registry.lookup_by_type_name(name)
        raise UndefinedParameterTypeError.new(node, @expression, name) if parameter_type.nil?

        @parameter_types.push(parameter_type)
        regexps = parameter_type.regexps
        return "(#{regexps[0]})" if regexps.length == 1

        "((?:#{regexps.join(')|(?:')}))"
      end

      def rewrite_expression(node)
        regex = node.nodes.map { |n| rewrite_to_regex(n) }.join('')
        "^#{regex}$"
      end

      def assert_not_empty(node, &raise_error)
        text_nodes = node.nodes.select { |ast_node| NodeType::TEXT == ast_node.type }
        raise_error.call(node) if text_nodes.length == 0
      end

      def assert_no_parameters(node, &raise_error)
        nodes = node.nodes.select { |ast_node| NodeType::PARAMETER == ast_node.type }
        raise_error.call(nodes[0]) if nodes.length > 0
      end

      def assert_no_optionals(node, &raise_error)
        nodes = node.nodes.select { |ast_node| NodeType::OPTIONAL == ast_node.type }
        raise_error.call(nodes[0]) if nodes.length > 0
      end
    end
  end
end
