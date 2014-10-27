require 'spec_helper'

describe JenkinsJsonPayload do

  let(:status_content) { JenkinsJsonExample.new(example_file).read }
  let(:payload) { JenkinsJsonPayload.new }
  let(:converted_content) { payload.convert_content!(status_content).first }
  let(:example_file) { "success.txt" }

  describe '#status_content' do
    subject { payload.status_content = status_content }

    context 'when content is valid' do
      let(:expected_content) { double }
      before do
        allow(JSON).to receive(:parse).and_return(expected_content)
      end

      it 'should parse content' do
        subject
        expect(payload.status_content).to eq([expected_content])
      end
    end

    context 'when content is corrupt / badly encoded' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        subject
        expect(payload.processable).to be false
        expect(payload.build_processable).to be false
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(converted_content) }

    context 'the payload contains a successful build status' do
      it { is_expected.to be true }
    end

    context 'the payload contains a failure build status' do
      let(:example_file) { "failure.txt" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(converted_content) }

    context 'the build has not finished' do
      let(:example_file) { "building.txt" }
      it { is_expected.to be false }
    end

    context 'the build has finished' do
      it { is_expected.to be true }
    end
  end

  describe '#parse_url' do
    subject { payload.parse_url(converted_content) }

    context 'should include the build endpoint' do
      it { is_expected.to include 'job/Pivots2-iOS/10/' }
    end

    context 'should include the root url' do
      it { is_expected.to include 'http://mobile-ci.nyc.pivotallabs.com:8080' }
    end

    context 'should handle not having a full_url' do
      let(:example_file) { "no_full_url.txt" }
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
