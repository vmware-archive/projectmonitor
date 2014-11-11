require 'spec_helper'

describe ConcoursePayload do
  let(:payload) { ConcoursePayload.new('http://concourse.example.com:8080/jobs/concourse-project/builds') }
  let(:content) { load_fixture('concourse_examples', fixture_file) }
  let(:fixture_file) { 'success.json' }
  let(:converted_content) { payload.convert_content!(content).first }

  context 'with invalid status content' do
    subject { payload.processable }
    before do
      expect(payload).to receive(:log_error)
      payload.status_content = content
    end

    context 'with empty string' do
      let(:content) { '' }
      it { is_expected.to be false }
    end

    context 'with unparseable JSON' do
      let(:content) { 'I am not valid JSON, now am I?' }
      it { is_expected.to be false }
    end

    context 'with unexpected type' do
      let(:content) { 1 }
      it { is_expected.to be false }
    end
  end

  context 'with valid content' do
    before { payload.build_status_content = content }
    subject { payload.parse_success(converted_content) }

    describe '#parse_success' do
      context 'with a successful build do' do
        it { is_expected.to be true }
      end

      context 'with an unsuccessful build' do
        let(:fixture_file) { 'failure.json' }
        it { is_expected.to be false }
      end
    end

    describe '#content_ready?' do
      subject { payload.content_ready?(converted_content) }

      context 'build has finished' do
        it { is_expected.to be true }
      end

      context 'build has not finished' do
        let(:fixture_file) { 'building.json' }
        it { is_expected.to be false }
      end
    end

    describe '#parse_url' do
      subject { payload.parse_url(converted_content) }
      it { is_expected.to eq('http://concourse.example.com:8080/jobs/concourse-project/builds/1') }
    end

    describe '#parse_build_id' do
      subject { payload.parse_build_id(converted_content) }
      it { is_expected.to eq("1") }
    end

    describe '#convert_webhook_content' do
      subject { payload.convert_webhook_content!(content) }
      it "raises an error" do
        expect{subject}.to raise_error NotImplementedError
      end
    end

    describe '#building?' do
      subject { payload }
      before { payload.build_status_content = content }

      context 'when building' do
        let(:fixture_file) { 'building.json' }
        it { is_expected.to be_building }
      end

      context 'when not building' do
        it { is_expected.not_to be_building }
      end
    end
  end
end
