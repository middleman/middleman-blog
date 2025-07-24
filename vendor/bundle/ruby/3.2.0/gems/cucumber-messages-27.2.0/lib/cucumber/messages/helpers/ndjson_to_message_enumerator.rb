# frozen_string_literal: true

require 'cucumber/messages'

module Cucumber
  module Messages
    module Helpers
      class NdjsonToMessageEnumerator < Enumerator
        def initialize(io)
          super() do |yielder|
            io.each_line do |line|
              next if line.strip.empty?

              message = extract_message(line)
              yielder.yield(message)
            end
          end
        end

        private

        def extract_message(json_line)
          Envelope.from_json(json_line)
        rescue StandardError
          raise "Not JSON: #{json_line.strip}"
        end
      end
    end
  end
end
