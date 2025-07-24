# frozen_string_literal: true

require 'cucumber/core/test/case'
require 'cucumber/core/test/data_table'
require 'cucumber/core/test/doc_string'
require 'cucumber/core/test/empty_multiline_argument'
require 'cucumber/core/test/hook_step'
require 'cucumber/core/test/step'
require 'cucumber/core/test/tag'
require 'cucumber/messages'

module Cucumber
  module Core
    # Compiles the Pickles into test cases
    class Compiler
      attr_reader :receiver, :gherkin_query, :id_generator
      private     :receiver, :gherkin_query, :id_generator

      def initialize(receiver, gherkin_query, event_bus = nil)
        @receiver = receiver
        @id_generator = Cucumber::Messages::Helpers::IdGenerator::UUID.new
        @gherkin_query = gherkin_query
        @event_bus = event_bus
      end

      def pickle(pickle)
        test_case = create_test_case(pickle)
        test_case.describe_to(receiver)
      end

      def done
        receiver.done
        self
      end

      private

      def create_test_case(pickle)
        uri = pickle.uri
        test_steps = pickle.steps.map { |step| create_test_step(step, uri) }
        location = location_from_pickle(pickle)
        parent_locations = parent_locations_from_pickle(pickle)
        tags = tags_from_pickle(pickle, uri)
        Test::Case.new(id_generator.new_id, pickle.name, test_steps, location, parent_locations, tags, pickle.language).tap do |test_case|
          @event_bus&.test_case_created(test_case, pickle)
        end
      end

      def create_test_step(pickle_step, uri)
        location = location_from_pickle_step(pickle_step, uri)
        multiline_arg = create_multiline_arg(pickle_step, uri)
        Test::Step.new(id_generator.new_id, pickle_step.text, location, multiline_arg).tap do |test_step|
          @event_bus&.test_step_created(test_step, pickle_step)
        end
      end

      def create_multiline_arg(pickle_step, _uri)
        if pickle_step.argument
          if pickle_step.argument.doc_string
            doc_string_from_pickle_step(pickle_step)
          elsif pickle_step.argument.data_table
            data_table_from_pickle_step(pickle_step)
          end
        else
          Test::EmptyMultilineArgument.new
        end
      end

      def location_from_pickle(pickle)
        lines = pickle.ast_node_ids.map { |id| source_line(id) }
        Test::Location.new(pickle.uri, lines.sort.reverse)
      end

      def parent_locations_from_pickle(pickle)
        parent_lines = gherkin_query.scenario_parent_locations(pickle.ast_node_ids[0]).map(&:line)
        Test::Location.new(pickle.uri, parent_lines)
      end

      def location_from_pickle_step(pickle_step, uri)
        lines = pickle_step.ast_node_ids.map { |id| source_line(id) }
        Test::Location.new(uri, lines.sort.reverse)
      end

      def tags_from_pickle(pickle, uri)
        pickle.tags.map do |tag|
          location = Test::Location.new(uri, source_line(tag.ast_node_id))
          Test::Tag.new(location, tag.name)
        end
      end

      def source_line(id)
        gherkin_query.location(id).line
      end

      def doc_string_from_pickle_step(pickle_step)
        doc_string = pickle_step.argument.doc_string
        Test::DocString.new(
          doc_string.content,
          doc_string.media_type
        )
      end

      def data_table_from_pickle_step(pickle_step)
        data_table = pickle_step.argument.data_table
        Test::DataTable.new(
          data_table.rows.map do |row|
            row.cells.map(&:value)
          end
        )
      end
    end
  end
end
