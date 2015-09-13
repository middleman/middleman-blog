begin
  require 'oga'
rescue LoadError
  raise "Oga is required for blog post summaries. Add 'oga' to your Gemfile."
end

module TruncateHTML
  def self.truncate_html(text, max_length, ellipsis = '...')
    ellipsis_length = ellipsis.length
    text = text.encode('UTF-8') if text.respond_to?(:encode)
    doc = Oga.parse_html(text)
    content_length = doc.children.text.length
    actual_length = max_length - ellipsis_length
    if content_length > actual_length
      doc.truncate(actual_length, ellipsis).to_xml
    else
      text
    end
  end
end

module OgaTruncator
  module DocumentTruncator
    def truncate(max_length, ellipsis)
      truncated_doc = Oga::XML::Document.new
      children.each do |child|
        remaining_length = max_length - truncated_doc.children.text.length
        break if remaining_length <= 0
        truncated_doc.children << child.truncate(remaining_length, ellipsis)
      end
      truncated_doc
    end
  end

  module ElementTruncator
    def truncate(max_length, ellipsis)
      return self if text.length <= max_length
      truncated_element = dup
      truncated_element.children = Oga::XML::NodeSet.new
      children.each do |child|
        remaining_length = max_length - truncated_element.text.length
        break if remaining_length <= 0
        truncated_element.children << child.truncate(remaining_length, ellipsis)
      end
      truncated_element
    end
  end

  module TextTruncator
    def truncate(max_length, ellipsis)
      # Don't break in the middle of a word
      trimmed_content = text.match(/(.{1,#{max_length}}[\w]*)/m).to_s
      trimmed_content << ellipsis if trimmed_content.length < text.length
      Oga::XML::Text.new(text: trimmed_content)
    end
  end

  module CommentTruncator
    def truncate(*_args)
      # Don't truncate comments, since they aren't visible
      self
    end
  end
end

Oga::XML::Document.send(:include, OgaTruncator::DocumentTruncator)
Oga::XML::Element.send(:include, OgaTruncator::ElementTruncator)
Oga::XML::Text.send(:include, OgaTruncator::TextTruncator)
Oga::XML::Comment.send(:include, OgaTruncator::CommentTruncator)
