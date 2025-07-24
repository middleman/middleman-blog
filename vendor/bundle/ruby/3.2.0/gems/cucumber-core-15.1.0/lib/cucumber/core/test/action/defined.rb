# frozen_string_literal: true

require 'cucumber/core/test/location'
require 'cucumber/core/test/result'
require 'cucumber/core/test/timer'

module Cucumber
  module Core
    module Test
      module Action
        class Defined
          attr_reader :location

          def initialize(location = nil, &block)
            raise ArgumentError, 'Passing a block to execute the action is mandatory.' unless block

            @location = location || Test::Location.new(*block.source_location)
            @block = block
            @timer = Timer.new
          end

          def execute(*args)
            @timer.start
            @block.call(*args)
            passed
          rescue Result::Raisable => e
            e.with_duration(@timer.duration)
          rescue Exception => e
            failed(e)
          end

          def inspect
            "#<#{self.class}: #{location}>"
          end

          def skip(*)
            skipped
          end

          private

          def passed
            Result::Passed.new(@timer.duration)
          end

          def failed(exception)
            Result::Failed.new(@timer.duration, exception)
          end

          def skipped
            Result::Skipped.new
          end
        end
      end
    end
  end
end
