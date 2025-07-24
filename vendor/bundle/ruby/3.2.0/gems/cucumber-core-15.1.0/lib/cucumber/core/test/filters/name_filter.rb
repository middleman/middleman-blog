# frozen_string_literal: true

require 'cucumber/core/filter'

module Cucumber
  module Core
    module Test
      class NameFilter < Filter.new(:name_regexps)
        def test_case(test_case)
          test_case.describe_to(receiver) if accept?(test_case)
          self
        end

        private

        def accept?(test_case)
          name_regexps.empty? || name_regexps.any? { |name_regexp| test_case.match_name?(name_regexp) }
        end
      end
    end
  end
end
