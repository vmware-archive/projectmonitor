require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe JenkinsJsonPayload do

  let(:fixture_file)      { "success.json" }
  let(:fixture_content)   { load_fixture('jenkins_json_examples', fixture_file) }
  let(:payload)           { JenkinsJsonPayload.new }
  let(:converted_content) { payload.convert_content!(fixture_content).first }

  it_behaves_like "a JSON payload"

  describe '#parse_url' do
    subject { payload.parse_url(converted_content) }

    context 'should include the build endpoint' do
      it { is_expected.to include 'job/Pivots2-iOS/10/' }
    end

    context 'should include the root url' do
      it { is_expected.to include 'http://mobile-ci.nyc.pivotallabs.com:8080' }
    end

    context 'should handle not having a full_url' do
      let(:fixture_file) { "no_full_url.json" }
      it { is_expected.to include 'job/projectmonitor_ci_test/' }
    end

  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(converted_content) }
    it { is_expected.to eq(10) }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(converted_content) }
    it { is_expected.to be_an_instance_of(Time) }
  end
end
