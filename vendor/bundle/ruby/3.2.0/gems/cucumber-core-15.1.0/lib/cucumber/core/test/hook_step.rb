# frozen_string_literal: true

require 'cucumber/core/test/step'

module Cucumber
  module Core
    module Test
      class HookStep < Step
        def initialize(id, text, location, action)
          super(id, text, location, Test::EmptyMultilineArgument.new, action)
        end

        def hook?
          true
        end
      end
    end
  end
end
