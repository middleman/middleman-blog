# frozen_string_literal: true

require 'securerandom'

module Cucumber
  module Messages
    module Helpers
      module IdGenerator
        class UUID
          def new_id
            SecureRandom.uuid
          end
        end
      end
    end
  end
end
