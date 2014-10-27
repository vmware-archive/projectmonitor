require 'spec_helper'

describe TddiumPayload do
  let(:project) { FactoryGirl.create(:tddium_project).tap {|p| p.tddium_project_name = 'Test A'} }
  let(:payload) { TddiumPayload.new('Test A') }
  let(:content) { TddiumExample.new(fixture_file).read }
  let(:fixture_file) { 'success.xml' }
  let(:converted_content) { payload.convert_content!(content).first }

  context 'with an invalid POST' do
    subject { payload.processable }
    before do
      expect(payload).to receive(:log_error)
      payload.status_content = content
    end

    context 'with empty string' do
      let(:content) { '' }
      it { is_expected.to be false }
    end

    context 'with unparseable XML' do
      let(:content) { 'I am not valid XML, now am I?' }
      it { is_expected.to be false }
    end

    context 'with unexpected type' do
      let(:content) { 1 }
      it { is_expected.to be false }
    end
  end

  context 'with a valid POST' do
    before { payload.build_status_content = content }
    subject { payload.parse_success(converted_content) }

    describe '#parse_success' do
      context 'with a successful build do' do
        it { is_expected.to be true }
      end

      context 'with an unsuccessful build' do
        let(:fixture_file) { 'failure.xml' }
        it { is_expected.to be false }
      end
    end

    describe '#content_ready?' do
      subject { payload.content_ready?(converted_content) }

      context 'build has finished' do
        it { is_expected.to be true }
      end

      context 'build has not finished' do
        let(:fixture_file) { 'building.xml' }
        it { is_expected.to be false }
      end
    end

    describe '#parse_url' do
      subject { payload.parse_url(converted_content) }
      it { is_expected.to eq('https://api.tddium.com/1/reports/1') }
    end

    describe '#parse_build_id' do
      subject { payload.parse_build_id(converted_content) }
      it { is_expected.to eq('45') }
    end

    describe '#parse_published_at' do
      subject { payload.parse_published_at(converted_content) }
      it { is_expected.to eq(Time.new(2012,8,22,14,30,2)) }
    end

    describe '#convert_webhook_content' do
      subject { payload.convert_webhook_content!(content) }
      it do
        expect do
          subject
        end.to raise_error NotImplementedError
      end
    end

    describe '#building?' do
      subject { payload }
      before { payload.build_status_content = content }

      context 'when building' do
        let(:fixture_file) { 'building.xml' }
        it { is_expected.to be_building }
      end

      context 'when not building' do
        it {is_expected.not_to be_building }
      end
    end
  end

  context 'with an actual POST request' do
    let(:fixture_file) { 'integration.xml' }
    let(:payload) { TddiumPayload.new('projectmonitor_ci_test (master)') }

    context '#parse_success' do
      before { payload.build_status_content = content }
      subject { payload.parse_success(converted_content) }
      it { is_expected.to be true }
    end

    context '#content_ready?' do
      before { payload.build_status_content = content }
      subject { payload.content_ready?(converted_content) }
      it { is_expected.to be true }
    end

    describe '#parse_url' do
      subject { payload.parse_url(converted_content) }
      it { is_expected.to eq('https://api.tddium.com/1/reports/72225') }
    end

    describe '#parse_build_id' do
      subject { payload.parse_build_id(converted_content) }
      it { is_expected.to eq('72225') }
    end

    describe '#parse_published_at' do
      subject { payload.parse_published_at(converted_content) }
      it { is_expected.to eq(Time.new(2012,8,22,14,30,2)) }
    end

    describe '#building?' do
      subject { payload }
      before { payload.build_status_content = content }
      it {is_expected.not_to be_building }
    end
  end
end
