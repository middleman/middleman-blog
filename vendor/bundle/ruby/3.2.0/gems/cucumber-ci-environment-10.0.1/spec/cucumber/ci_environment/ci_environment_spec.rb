# frozen_string_literal: true

require 'cucumber/ci_environment'
require 'json'

describe 'detect_ci_environment' do
  Dir.glob('../testdata/*.txt') do |test_data_file|
    context "with #{File.basename(test_data_file, '.txt')}" do
      subject { JSON.parse(ci_environment.to_json) }

      let(:ci_environment) { Cucumber::CiEnvironment.detect_ci_environment(env) }
      let(:env) { Hash[entries] }
      let(:entries) { env_data.split(/\n/).map { |line| line.split(/=/) } }
      let(:env_data) { IO.read(test_data_file) }

      let(:expected_json) { File.read("#{test_data_file}.json") }

      it { is_expected.to eq JSON.parse(expected_json) }
    end
  end

  context 'with no CI environment' do
    subject { JSON.parse(ci_environment.to_json) }
    let(:ci_environment) { Cucumber::CiEnvironment.detect_ci_environment(env) }
    let(:env) { {} }

    it { is_expected.to be_nil }
  end
end
