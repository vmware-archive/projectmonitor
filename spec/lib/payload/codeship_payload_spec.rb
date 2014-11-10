require 'spec_helper'

describe CodeshipPayload do
  let(:payload) { CodeshipPayload.new(45716) }
  let(:content) { CodeshipExample.new(fixture_file).read }
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
    before(:each)  { payload.build_status_content = content }

    describe '#parse_success' do
      subject { payload.parse_success(converted_content) }

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
      before(:each) {}
      subject { payload.parse_url(converted_content) }
      it { is_expected.to eq('https://www.codeship.io/projects/45716/builds/2776509') }
    end

    describe '#parse_build_id' do
      subject { payload.parse_build_id(converted_content) }

      context 'polled content' do
        it { is_expected.to eq(2776509) }
      end

      context 'webhook content' do
        let(:fixture_file) { 'webhook.json' }
        let(:converted_webhook_content) { payload.convert_webhook_content!(JSON.parse(content)).first }

        it { expect(payload.parse_build_id(converted_webhook_content)).to eq(2778736) }
      end
    end

    describe '#convert_webhook_content' do
      let(:fixture_file) { 'webhook.json' }
      subject { CodeshipPayload.new(nil) }

      it "converts the webhook content" do
        expect(subject.convert_webhook_content!(JSON.parse(content)).first.keys).to include 'build_id', 'project_id'
      end

      it "sets the Project ID" do
        expect{ subject.convert_webhook_content!(JSON.parse(content)) }
          .to change{ subject.instance_variable_get(:@project_id) }.from(nil).to(45716)
      end
    end

    describe '#building?' do
      subject { payload }
      before(:each)  { payload.build_status_content = content }

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
