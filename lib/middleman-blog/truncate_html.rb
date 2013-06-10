begin
  require "nokogiri"
rescue LoadError
  raise "Nokogiri is required for blog post summaries. Add 'nokogiri' to your Gemfile."
end

# Taken and modified from http://madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html
# MIT license
module TruncateHTML
  def self.truncate_html(text, max_length, ellipsis = "...")
    ellipsis_length = ellipsis.length
    text = text.encode('UTF-8') if text.respond_to?(:encode)
    doc = Nokogiri::HTML::DocumentFragment.parse text
    content_length = doc.inner_text.length
    actual_length = max_length - ellipsis_length
    if content_length > actual_length 
      doc.truncate(actual_length, ellipsis).inner_html
    else
      text
    end
  end
end

module NokogiriTruncator
  module NodeWithChildren
    def truncate(max_length, ellipsis)
      return self if inner_text.length <= max_length
      truncated_node = self.dup
      truncated_node.children.remove

      self.children.each do |node|
        remaining_length = max_length - truncated_node.inner_text.length
        break if remaining_length <= 0
        truncated_node.add_child node.truncate(remaining_length, ellipsis)
      end
      truncated_node
    end
  end

  module TextNode
    def truncate(max_length, ellipsis)
      # Don't break in the middle of a word
      trimmed_content = content.match(/(.{1,#{max_length}}[\w]*)/m).to_s
      trimmed_content << ellipsis if trimmed_content.length < content.length

      Nokogiri::XML::Text.new(trimmed_content, parent)
    end
  end

  module CommentNode
    def truncate(*args)
      # Don't truncate comments, since they aren't visible
      self
    end
  end

end

Nokogiri::HTML::DocumentFragment.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Element.send(:include, NokogiriTruncator::NodeWithChildren)
Nokogiri::XML::Text.send(:include, NokogiriTruncator::TextNode)
Nokogiri::XML::Comment.send(:include, NokogiriTruncator::CommentNode)
