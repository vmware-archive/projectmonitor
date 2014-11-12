require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe TravisJsonPayload do

  let(:fixture_file)      { "success.json" }
  let(:fixture_content)   { load_fixture('travis_examples', fixture_file) }
  let(:payload)           { TravisJsonPayload.new.tap{|p| p.status_content = fixture_content} }
  let(:converted_content) { payload.status_content.first }

  it_behaves_like "a JSON payload"

  describe '#convert_webhook_content!' do
    context 'when supplied with valid webhook content' do
      let(:fixture_file) { "webhook_success.txt" }

      let(:webhook_content) {
        # Mimic controller
        payload_content = Rack::Utils.parse_nested_query(fixture_content)
        ActionController::Parameters.new(payload_content)
      }

      it 'parses the content' do
        converted_content = TravisJsonPayload.new.convert_webhook_content!(webhook_content)
        expect(converted_content.first['id']).to eq(12150190)
      end
    end

    context 'when supplied with an empty payload' do
      it 'raises an exception' do
        expect { TravisJsonPayload.new.convert_webhook_content!("") }
          .to raise_error Payload::InvalidContentException
      end
    end
  end

  describe '#parse_success' do
    # success.json & failure.json covered in shared examples
    subject { payload.parse_success(converted_content) }

    context 'the payload build has errored' do
      let(:fixture_file) { "errored.json" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    # success.json & building.json covered in shared examples

    subject { payload.content_ready?(converted_content) }

    context 'the payload build has not started running' do
      let(:fixture_file) { "created.json" }
      it { is_expected.to be false }
    end

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

    context 'the payload contains a build from pull request' do
      let(:fixture_file) { "pull_request.json" }
      it { is_expected.to be false }
    end
  end

  describe '#parse_url' do
    subject { payload }

    context "no slug exists" do
      it { expect(payload.parse_url(converted_content)).to eq("https://api.travis-ci.org/builds/4314974") }
    end

    context "a slug exists" do
      let!(:slug) { payload.slug = "account/project" }
      it { expect(payload.parse_url(converted_content)).to eq("https://travis-ci.org/account/project/builds/4314974") }
    end

    context "a travis pro project" do
      it "uses the magnum base URL" do
        payload.is_travis_pro = true
        payload.slug = "account/project"
        expect(payload.parse_url(converted_content)).to eq("https://magnum.travis-ci.com/account/project/builds/4314974")
      end
    end
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(converted_content) }
    it { is_expected.to eq(4314974) }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(converted_content) }
    it { is_expected.to eq(Time.utc(2013, 1, 22, 21, 16, 20)) }
  end

  describe '#branch=' do
    it "is set when given a name" do
      expect{ payload.branch = "staging" }.to change{ payload.branch }.from("master").to("staging")
    end

    it "remains 'master' when given an empty string" do
      expect{ payload.branch = "" }.to_not change{ payload.branch }.from("master")
    end
  end

  describe '#building?' do
    # success.json & building.json covered in shared examples

    before(:each) { payload.status_content = fixture_content }
    subject { payload }

    context 'the payload build has failed' do
      let(:fixture_file) { "errored.json" }
      it { is_expected.not_to be_building }
    end

    context 'the payload build has errored' do
      let(:fixture_file) { "failure.json" }
      it { is_expected.not_to be_building }
    end

    context 'the payload build has not started running' do
      let(:fixture_file) { "created.json" }
      it { is_expected.to be_building }
    end
  end
end
