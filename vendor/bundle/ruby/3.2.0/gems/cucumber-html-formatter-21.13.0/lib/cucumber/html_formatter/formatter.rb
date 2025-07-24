# frozen_string_literal: true

require 'cucumber/messages'
require 'cucumber/html_formatter/template_writer'
require 'cucumber/html_formatter/assets_loader'

module Cucumber
  module HTMLFormatter
    class Formatter
      attr_reader :out

      def initialize(out)
        @out = out
        @pre_message_written = false
        @first_message = true
      end

      def process_messages(messages)
        write_pre_message
        messages.each { |message| write_message(message) }
        write_post_message
      end

      def write_message(message)
        out.puts(',') unless @first_message
        out.print(message.to_json.gsub('/', '\/'))

        @first_message = false
      end

      def write_pre_message
        return if @pre_message_written

        out.puts(pre_message)
        @pre_message_written = true
      end

      def write_post_message
        out.print(post_message)
      end

      private

      def pre_message
        [
          template_writer.write_between(nil, '{{css}}'),
          AssetsLoader.css,
          template_writer.write_between('{{css}}', '{{messages}}')
        ].join("\n")
      end

      def post_message
        [
          template_writer.write_between('{{messages}}', '{{script}}'),
          AssetsLoader.script,
          template_writer.write_between('{{script}}', nil)
        ].join("\n")
      end

      def template_writer
        @template_writer ||= TemplateWriter.new(AssetsLoader.template)
      end
    end
  end
end
