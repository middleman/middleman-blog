# frozen_string_literal: true

require 'cucumber/core/test/result'
require 'cucumber/core/test/action/defined'

module Cucumber
  module Core
    module Test
      module Action
        class Unskippable < Defined
          def skip(*args)
            execute(*args)
          end
        end
      end
    end
  end
end
