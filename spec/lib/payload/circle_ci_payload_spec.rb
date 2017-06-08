require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe CircleCiPayload do

  let(:fixture_file)      { "success.json" }
  let(:fixture_content)   { load_fixture('circleci_examples', fixture_file) }
  let(:payload)           { CircleCiPayload.new.tap{|p| p.status_content = fixture_content} }
  let(:converted_content) { payload.status_content.first }

  it_behaves_like "a JSON payload"

  describe '#content_ready?' do
    # success.json & failure.json covered in shared examples
    context 'outcome is empty' do
      let(:fixture_file) { "outcome_is_empty.json" }
      it { expect(payload.content_ready?(converted_content)).to be false }
    end

    context 'the payload contains a build from a branch other than the desired branch' do
      subject { payload.content_ready?(converted_content) }

      before { payload.branch = 'staging' }

      it { is_expected.to be false }
    end

    context 'project is set up to use wildcard branch' do
      # let(:payload) { CircleCiPayload.new.tap{|p| p.status_content = fixture_content} }

      subject { payload.content_ready?(converted_content) }

      before { payload.branch = '*' }

      it { is_expected.to be true }
    end
  end

  describe '#parse_url' do
    it { expect(payload.parse_url(converted_content)).to eq('https://circleci.com/gh/auser/project/172') }
  end

  describe '#parse_build_id' do
    it { expect(payload.parse_build_id(converted_content)).to eq(172) }
  end

  describe '#parse_published_at' do
    it { expect(payload.parse_published_at(converted_content).round).to eq(Time.utc(2013, 10, 15, 8, 47, 30)) }
  end

  describe '#convert_webhook_content' do
    let(:fixture_file) { 'webhook.json' }
    subject { CircleCiPayload.new }

    it "converts the webhook content" do
      expect(subject.convert_webhook_content!(JSON.parse(fixture_content)).first.keys).to include 'build_num', 'build_url'
    end
  end
end
