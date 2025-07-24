# frozen_string_literal: true

module Cucumber
  module Messages
    module Helpers
      module IdGenerator
        class Incrementing
          def initialize
            @index = -1
          end

          def new_id
            @index += 1
            @index.to_s
          end
        end
      end
    end
  end
end
