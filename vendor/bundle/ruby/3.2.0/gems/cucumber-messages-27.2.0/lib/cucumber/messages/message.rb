# frozen_string_literal: true

require 'json'

module Cucumber
  module Messages
    class Message
      def self.camelize(term)
        camelized = term.to_s
        camelized.gsub(/(?:_|(\/))([a-z\d]*)/i) { "#{Regexp.last_match(1)}#{Regexp.last_match(2).capitalize}" }
      end

      ##
      # Returns a new Message - or messages into an array - deserialized from the given json document.
      # CamelCased keys are properly converted to snake_cased attributes in the process
      #
      #   Cucumber::Messages::Duration.from_json('{"seconds":1,"nanos":42}')
      #     # => #<Cucumber::Messages::Duration:0x00007efda134c290 @seconds=1, @nanos=42>
      #   Cucumber::Messages::PickleTag.from_json('{"name":"foo","astNodeId":"abc-def"}')
      #     # => #<Cucumber::Messages::PickleTag:0x00007efda138cdb8 @name="foo", @ast_node_id="abc-def">
      #
      # It is recursive so embedded messages are also processed.
      #
      #   json_string = { location: { line: 2 }, text: "comment" }.to_json
      #   Cucumber::Messages::Comment.from_json(json_string)
      #     # => #<Cucumber::Messages::Comment:0x00007efda6abf888 @location=#<Cucumber::Messages::Location:0x00007efda6abf978 @line=2, @column=nil>, @text="comment">
      #
      #   json_string = { uri: 'file:///...', comments: [{text: 'text comment'}, {text: 'another comment'}]}.to_json
      #   Cucumber::Messages::GherkinDocument.from_json(json_string)
      #     # => #<Cucumber::Messages::GherkinDocument:0x00007efda11e6a90 ... @comments=[#<Cucumber::Messages::Comment:0x00007efda11e6e50 ...]>
      ##
      def self.from_json(json_string)
        from_h(JSON.parse(json_string, { symbolize_names: true }))
      end

      ##
      # Returns a new Hash formed from the message attributes
      # If +camelize:+ keyword parameter is set to true, then keys will be camelized
      # If +reject_nil_values:+ keyword parameter is set to true, resulting hash won't include nil values
      #
      #   Cucumber::Messages::Duration.new(seconds: 1, nanos: 42).to_h
      #     # => { seconds: 1, nanos: 42 }
      #   Cucumber::Messages::PickleTag.new(name: 'foo', ast_node_id: 'abc-def').to_h(camelize: true)
      #     # => { name: 'foo', astNodeId: 'abc-def' }
      #   Cucumber::Messages::PickleTag.new(name: 'foo', ast_node_id: nil).to_h(reject_nil_values: true)
      #     # => { name: 'foo' }
      #
      # It is recursive so embedded messages are also processed
      #
      #   location = Cucumber::Messages::Location.new(line: 2)
      #   Cucumber::Messages::Comment.new(location: location, text: 'comment').to_h
      #     # => { location: { line: 2, :column: nil }, text: "comment" }
      ##
      def to_h(camelize: false, reject_nil_values: false)
        resulting_hash = instance_variables.to_h do |variable_name|
          h_key = variable_name[1..]
          h_key = Cucumber::Messages::Message.camelize(h_key) if camelize
          h_value = prepare_value(instance_variable_get(variable_name), camelize: camelize, reject_nil_values: reject_nil_values)
          [h_key.to_sym, h_value]
        end

        resulting_hash.tap { |hash| hash.compact! if reject_nil_values }
      end

      ##
      # Generates a JSON document from the message.
      # Keys are camelized during the process. Null values are not part of the json document.
      #
      #   Cucumber::Messages::Duration.new(seconds: 1, nanos: 42).to_json
      #     # => '{"seconds":1,"nanos":42}'
      #   Cucumber::Messages::PickleTag.new(name: 'foo', ast_node_id: 'abc-def').to_json
      #     # => '{"name":"foo","astNodeId":"abc-def"}'
      #   Cucumber::Messages::PickleTag.new(name: 'foo', ast_node_id: nil).to_json
      #     # => '{"name":"foo"}'
      #
      # As with #to_h, the method is recursive
      #
      #   location = Cucumber::Messages::Location.new(line: 2)
      #   Cucumber::Messages::Comment.new(location: location, text: 'comment').to_json
      #     # => '{"location":{"line":2,"column":null},"text":"comment"}'
      ##
      def to_json(*_args)
        to_h(camelize: true, reject_nil_values: true).to_json
      end

      private

      def prepare_value(value, camelize:, reject_nil_values:)
        if value.is_a?(Cucumber::Messages::Message)
          value.to_h(camelize: camelize, reject_nil_values: reject_nil_values)
        elsif value.is_a?(Array)
          value.map { |element| prepare_value(element, camelize: camelize, reject_nil_values: reject_nil_values) }
        else
          value
        end
      end
    end
  end
end
