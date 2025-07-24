# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/messages/helpers/time_conversion'

module Cucumber
  module Core
    module Test
      module Result
        TYPES = %i[failed flaky skipped undefined pending passed unknown].freeze
        STRICT_AFFECTED_TYPES = %i[flaky undefined pending].freeze

        def self.ok?(type, strict: StrictConfiguration.new)
          class_name = type.to_s.slice(0, 1).capitalize + type.to_s.slice(1..-1)
          const_get(class_name).ok?(strict: strict.strict?(type))
        end

        # Defines to_sym on a result class for the given result type
        #
        # Defines predicate methods on a result class with only the given one returning true
        def self.query_methods(result_type)
          Module.new do
            define_method :to_sym do
              result_type
            end

            TYPES.each do |possible_result_type|
              define_method("#{possible_result_type}?") do
                possible_result_type == to_sym
              end
            end
          end
        end

        # Null object for results. Represents the state where we haven't run anything yet
        class Unknown
          include Result.query_methods :unknown

          def describe_to(_visitor, *_args)
            self
          end

          def with_filtered_backtrace(_filter)
            self
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::UNKNOWN,
              duration: UnknownDuration.new.to_message_duration
            )
          end
        end

        class Passed
          include Result.query_methods :passed
          attr_accessor :duration

          def self.ok?(*)
            true
          end

          def initialize(duration)
            raise ArgumentError unless duration

            @duration = duration
          end

          def describe_to(visitor, *args)
            visitor.passed(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            '✓'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::PASSED,
              duration: duration.to_message_duration
            )
          end

          def ok?(*)
            self.class.ok?
          end

          def with_appended_backtrace(_step)
            self
          end

          def with_filtered_backtrace(_filter)
            self
          end
        end

        class Failed
          include Result.query_methods :failed

          attr_reader :duration, :exception

          def self.ok?(*)
            false
          end

          def initialize(duration, exception)
            raise ArgumentError unless duration
            raise ArgumentError unless exception

            @duration = duration
            @exception = exception
          end

          def describe_to(visitor, *args)
            visitor.failed(*args)
            visitor.duration(duration, *args)
            visitor.exception(exception, *args) if exception
            self
          end

          def to_s
            '✗'
          end

          def to_message
            begin
              message = exception.backtrace.join("\n")
            rescue NoMethodError
              message = ''
            end

            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::FAILED,
              duration: duration.to_message_duration,
              message: message
            )
          end

          def ok?(*)
            self.class.ok?
          end

          def with_duration(new_duration)
            self.class.new(new_duration, exception)
          end

          def with_appended_backtrace(step)
            exception.backtrace << step.backtrace_line if step.respond_to?(:backtrace_line)
            self
          end

          def with_filtered_backtrace(filter)
            self.class.new(duration, filter.new(exception.dup).exception)
          end
        end

        # Flaky is not used directly as an execution result, but is used as a
        # reporting result type for test cases that fails and the passes on
        # retry, therefore only the class method self.ok? is needed.
        class Flaky
          def self.ok?(strict: false)
            !strict
          end
        end

        # Base class for exceptions that can be raised in a step definition causing the step to have that result.
        class Raisable < StandardError
          attr_reader :message, :duration

          def initialize(message = '', duration = UnknownDuration.new, backtrace = nil)
            @message = message
            @duration = duration
            super(message)
            set_backtrace(backtrace) if backtrace
          end

          def with_message(new_message)
            self.class.new(new_message, duration, backtrace)
          end

          def with_duration(new_duration)
            self.class.new(message, new_duration, backtrace)
          end

          def with_appended_backtrace(step)
            return self unless step.respond_to?(:backtrace_line)

            set_backtrace([]) unless backtrace
            backtrace << step.backtrace_line
            self
          end

          def with_filtered_backtrace(filter)
            return self unless backtrace

            filter.new(dup).exception
          end

          def ok?(strict: StrictConfiguration.new)
            self.class.ok?(strict: strict.strict?(to_sym))
          end
        end

        class Undefined < Raisable
          include Result.query_methods :undefined

          def self.ok?(strict: false)
            !strict
          end

          def describe_to(visitor, *args)
            visitor.undefined(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            '?'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::UNDEFINED,
              duration: duration.to_message_duration
            )
          end
        end

        class Skipped < Raisable
          include Result.query_methods :skipped

          def self.ok?(*)
            true
          end

          def describe_to(visitor, *args)
            visitor.skipped(*args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            '-'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::SKIPPED,
              duration: duration.to_message_duration
            )
          end
        end

        class Pending < Raisable
          include Result.query_methods :pending

          def self.ok?(strict: false)
            !strict
          end

          def describe_to(visitor, *args)
            visitor.pending(self, *args)
            visitor.duration(duration, *args)
            self
          end

          def to_s
            'P'
          end

          def to_message
            Cucumber::Messages::TestStepResult.new(
              status: Cucumber::Messages::TestStepResultStatus::PENDING,
              duration: duration.to_message_duration
            )
          end
        end

        # Handles the strict settings for the result types that are
        # affected by the strict options (that is the STRICT_AFFECTED_TYPES).
        class StrictConfiguration
          attr_accessor :settings
          private :settings

          def initialize(strict_types = [])
            @settings = STRICT_AFFECTED_TYPES.to_h { |t| [t, :default] }
            strict_types.each do |type|
              set_strict(true, type)
            end
          end

          def strict?(type = nil)
            if type.nil?
              settings.each_value do |value|
                return true if value == true
              end
              false
            else
              return false unless settings.key?(type)
              return false unless set?(type)

              settings[type]
            end
          end

          def set_strict(setting, type = nil)
            if type.nil?
              STRICT_AFFECTED_TYPES.each { |type| set_strict(setting, type) }
            else
              settings[type] = setting
            end
          end

          def merge!(other)
            settings.each_key do |type|
              set_strict(other.strict?(type), type) if other.set?(type)
            end
            self
          end

          def set?(type)
            settings[type] != :default
          end
        end

        #
        # An object that responds to the description protocol from the results and collects summary information.
        #
        # e.g.
        #     summary = Result::Summary.new
        #     Result::Passed.new(0).describe_to(summary)
        #     puts summary.total_passed
        #     => 1
        #
        class Summary
          attr_reader :exceptions, :durations

          def initialize
            @totals = Hash.new { 0 }
            @exceptions = []
            @durations = []
          end

          def method_missing(name, *_args)
            if name =~ /^total_/
              get_total(name)
            else
              increment_total(name)
            end
          end

          def respond_to_missing?(*)
            true
          end

          def ok?(strict: StrictConfiguration.new)
            TYPES.each do |type|
              return false if get_total(type).positive? && !Result.ok?(type, strict: strict)
            end
            true
          end

          def exception(exception)
            @exceptions << exception
            self
          end

          def duration(duration)
            @durations << duration
            self
          end

          def total(for_status = nil)
            if for_status
              @totals.fetch(for_status, 0)
            else
              @totals.values.reduce(0) { |total, count| total + count }
            end
          end

          def decrement_failed
            @totals[:failed] -= 1
          end

          private

          def get_total(method_name)
            status = method_name.to_s.gsub('total_', '').to_sym
            @totals.fetch(status, 0)
          end

          def increment_total(status)
            @totals[status] += 1
            self
          end
        end

        class Duration
          include Cucumber::Messages::Helpers::TimeConversion

          attr_reader :nanoseconds

          def initialize(nanoseconds)
            @nanoseconds = nanoseconds
          end

          def to_message_duration
            duration_hash = seconds_to_duration(nanoseconds.to_f / NANOSECONDS_PER_SECOND)
            duration_hash.transform_keys! do |key|
              key.to_sym
            rescue Error
              return key
            end

            Cucumber::Messages::Duration.from_h(duration_hash)
          end
        end

        class UnknownDuration
          include Cucumber::Messages::Helpers::TimeConversion

          def tap
            self
          end

          def nanoseconds
            raise '#nanoseconds only allowed to be used in #tap block'
          end

          def to_message_duration
            Cucumber::Messages::Duration.new(seconds: 0, nanos: 0)
          end
        end
      end
    end
  end
end
