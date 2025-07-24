# frozen_string_literal: true

require 'cucumber/core/test/result'

module Cucumber
  module Core
    module Test
      module Action
        class Undefined
          attr_reader :location

          def initialize(source_location)
            @location = source_location
          end

          def execute(*)
            undefined
          end

          def skip(*)
            undefined
          end

          private

          def undefined
            Result::Undefined.new
          end
        end
      end
    end
  end
end
