require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe ConcoursePayload do

  let(:fixture_file)    { 'success.json' }
  let(:fixture_content) { load_fixture('concourse_examples', fixture_file) }
  let(:payload) { ConcoursePayload.new('http://concourse.example.com:8080/jobs/concourse-project/builds') }
  let(:converted_content) { payload.convert_content!(fixture_content).first }

  it_behaves_like 'a JSON payload'

  context 'with valid content' do
    describe '#parse_url' do
      subject { payload.parse_url(converted_content) }
      it { is_expected.to eq('http://concourse.example.com:8080/jobs/concourse-project/builds/1') }
    end

    describe '#parse_build_id' do
      subject { payload.parse_build_id(converted_content) }
      it { is_expected.to eq('1') }
    end

    describe '#parse_published_at' do
      subject { payload.parse_published_at(converted_content) }
      it { is_expected.to eq(Time.at(1472578253)) }
    end

    describe '#convert_webhook_content' do
      subject { payload.convert_webhook_content!(fixture_content) }
      it 'raises an error' do
        expect{subject}.to raise_error NotImplementedError
      end
    end
  end
end
