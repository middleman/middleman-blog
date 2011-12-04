PROJECT_ROOT_PATH = File.dirname(File.dirname(File.dirname(__FILE__)))
require "middleman"
require "middleman/step_definitions"
require File.join(PROJECT_ROOT_PATH, 'lib', 'middleman-blog')