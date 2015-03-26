require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe SemaphorePayload do

  let(:fixture_file)      { "success.json" }
  let(:fixture_content)   { load_fixture('semaphore_examples', fixture_file) }
  let(:payload)           { SemaphorePayload.new.tap{|p| p.status_content = fixture_content} }
  let(:converted_content) { payload.status_content.first }

  it_behaves_like "a JSON payload"

  describe '#convert_content!' do
    context 'when the project has a branch history url' do
      let(:fixture_file) { "success_history.json" }

      it "should return the builds array" do
        history_content = payload.convert_content!(fixture_content)
        expect(history_content.count).to eq(2)
      end
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(converted_content) }

    context 'the payload contains a build from a branch other than master' do
      let(:fixture_file) { "branch.json" }

      context 'and the branch has not been specified' do
        it { is_expected.to be false }
      end

      context 'and the branch has been specified' do
        before { payload.branch = 'staging' }

        it { is_expected.to be true }
      end
    end
  end

  describe '#parse_url' do
    it { expect(payload.parse_url(converted_content)).to eq('https://semaphoreci.com/projects/123/branches/456/builds/1') }
  end

  describe '#parse_build_id' do
    it { expect(payload.parse_build_id(converted_content)).to eq(1) }
  end

  describe '#parse_published_at' do
    it { expect(payload.parse_published_at(converted_content)).to eq(Time.new(2012, 8, 16, 2, 15, 34, "-07:00")) }
  end

end
