# frozen_string_literal: true

require 'rspec'
require 'sys/uname'

RSpec.configure do |config|
  config.filter_run_excluding(:bsd) unless RbConfig::CONFIG['host_os'] =~ /powerpc|darwin|macos|bsd|dragonfly/i
  config.filter_run_excluding(:hpux) unless RbConfig::CONFIG['host_os'] =~ /hpux/i
  config.filter_run_excluding(:linux) unless RbConfig::CONFIG['host_os'] =~ /linux/i
  config.filter_run_excluding(:windows) unless Gem.win_platform?
end
