# frozen_string_literal: true

##############################################################################
# sys_platform_spec.rb
#
# Test suite for the Sys::Platform class.
##############################################################################
require 'spec_helper'

RSpec.describe Sys::Platform do
  example 'the VERSION constant is set to the expected value' do
    expect(Sys::Platform::VERSION).to eql('1.3.1')
    expect(Sys::Platform::VERSION).to be_frozen
  end

  example 'the ARCH constant is defined' do
    expect(Sys::Platform::ARCH).to be_a(Symbol)
  end

  example 'the OS constant is defined' do
    expect(Sys::Platform::OS).to be_a(Symbol)
  end

  example 'the IMPL constant is defined' do
    expect(Sys::Platform::IMPL).to be_a(Symbol)
  end

  example 'the IMPL returns an expected value on windows', :windows do
    expect(%i[mingw mswin]).to include(Sys::Platform::IMPL)
  end

  example 'the mac? method is defined and returns a boolean' do
    expect(described_class).to respond_to(:mac?)
    expect(described_class.mac?).to eql(true).or eql(false)
  end

  example 'the windows? method is defined and returns a boolean' do
    expect(described_class).to respond_to(:windows?)
    expect(described_class.windows?).to eql(true).or eql(false)
  end

  example 'the windows? method returns the expected value' do
    expect(described_class.windows?).to eql(Gem.win_platform?)
  end

  example 'the unix? method is defined and returns a boolean' do
    expect(described_class).to respond_to(:unix?)
    expect(described_class.unix?).to eql(true).or eql(false)
  end

  example 'the unix? method returns the expected value' do
    expect(described_class.unix?).not_to eql(Gem.win_platform?)
  end

  example 'the linux? method is defined and returns a boolean' do
    expect(described_class).to respond_to(:linux?)
    expect(described_class.linux?).to eql(true).or eql(false)
  end

  example 'the bsd? method is defined and returns a boolean' do
    expect(described_class).to respond_to(:bsd?)
    expect(described_class.bsd?).to eql(true).or eql(false)
  end
end
