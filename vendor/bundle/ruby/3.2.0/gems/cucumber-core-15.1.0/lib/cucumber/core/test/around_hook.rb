# frozen_string_literal: true

module Cucumber
  module Core
    module Test
      class AroundHook
        def initialize(&block)
          @block = block
          @timer = Timer.new
        end

        def describe_to(visitor, *args, &continue)
          visitor.around_hook(self, *args, &continue)
        end

        def hook?
          true
        end

        def execute(*_args, &continue)
          @timer.start
          @block.call(continue)
          Result::Unknown.new # Around hook does not know the result of the inner test steps
        rescue Result::Raisable => e
          e.with_duration(@timer.duration)
        rescue Exception => e
          failed(e)
        end

        private

        def failed(exception)
          Result::Failed.new(@timer.duration, exception)
        end
      end
    end
  end
end
