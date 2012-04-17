require "middleman-core/templates"

module Middleman
  module Blog

    # A template that generates a blog-specific config.rb
    # and a set of example templates for index, layout, tags, and calendar.
    class Template < Middleman::Templates::Base
      class_option "css_dir", 
        :default => "stylesheets", 
        :desc    => 'The path to the css files'
      class_option "js_dir", 
        :default => "javascripts", 
        :desc    => 'The path to the javascript files'
      class_option "images_dir", 
        :default => "images", 
        :desc    => 'The path to the image files'

      def self.source_root
        File.join(File.dirname(__FILE__), 'template')
      end
  
      def build_scaffold
        template "config.tt", File.join(location, "config.rb")
        directory "source", File.join(location, "source")
    
        empty_directory File.join(location, "source", options[:css_dir])
        empty_directory File.join(location, "source", options[:js_dir])
        empty_directory File.join(location, "source", options[:images_dir])
      end
    end
  end
end

Middleman::Templates.register(:blog, Middleman::Blog::Template)
