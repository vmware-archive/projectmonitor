require 'spec_helper'

describe TravisJsonPayload do

  let(:status_content) { load_fixture('travis_examples', fixture_file) }
  let(:payload) { TravisJsonPayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:fixture_file) { "success.json" }

  describe '#status_content' do
    subject { payload.status_content = status_content }

    context 'when content is valid' do
      let(:expected_content) { double(:expected_content, "[]" => nil) }
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
        expect(payload.processable).to be false
        expect(payload.build_processable).to be false
      end

      let(:wrong_status_content) { "some non xml content" }
      it "should log errors" do
        expect(payload).to receive("log_error")
        payload.status_content = wrong_status_content
      end
    end
  end

  describe '#convert_webhook_content!' do
    context 'when supplied with valid webhook content' do
      let(:fixture_file) { "webhook_success.txt" }

      let(:webhook_content) {
        # Mimic controller
        payload_content = Rack::Utils.parse_nested_query(status_content)
        ActionController::Parameters.new(payload_content)
      }

      it 'parses the content' do
        converted_content = TravisJsonPayload.new.convert_webhook_content!(webhook_content)
        expect(converted_content.first['id']).to eq(12150190)
      end
    end

    context 'when supplied with an empty payload' do
      let(:webhook_content) { "" }
      it 'raises an exception' do
        expect {
          TravisJsonPayload.new.convert_webhook_content!(webhook_content)
        }.to raise_error Payload::InvalidContentException
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload result is a success' do
      let(:fixture_file) { "success.json" }
      it { is_expected.to be true }
    end

    context 'the payload result is a failure' do
      let(:fixture_file) { "failure.json" }
      it { is_expected.to be false }
    end

    context 'the payload build has errored' do
      let(:fixture_file) { "errored.json" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(content) }

    context 'the payload build has finished running' do
      let(:fixture_file) { "success.json" }
      it { is_expected.to be true }
    end

    context 'the payload build has not finished running' do
      let(:fixture_file) { "building.json" }
      it { is_expected.to be false }
    end

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
      it { expect(payload.parse_url(content)).to eq("https://api.travis-ci.org/builds/4314974") }
    end

    context "a slug exists" do
      let!(:slug) { payload.slug = "account/project" }
      it { expect(payload.parse_url(content)).to eq("https://travis-ci.org/account/project/builds/4314974") }
    end

    context "a travis pro project" do
      it "uses the magnum base URL" do
        payload.is_travis_pro = true
        payload.slug = "account/project"
        expect(payload.parse_url(content)).to eq("https://magnum.travis-ci.com/account/project/builds/4314974")
      end
    end
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { is_expected.to eq(4314974) }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content) }
    it { is_expected.to eq(Time.utc(2013, 1, 22, 21, 16, 20)) }
  end

  describe '#branch=' do
    subject { payload.branch }
    before { payload.branch = branch }

    context "when given a branch name" do
      let(:branch) { "staging" }
      it { is_expected.to eq(branch) }
    end

    context "when given an empty string" do
      let(:branch) { "" }
      it { is_expected.to eq("master") }
    end
  end

  describe '#building?' do
    before { payload.status_content = status_content }

    subject { payload }

    context 'the payload build has failed' do
      let(:fixture_file) { "errored.json" }
      it { is_expected.not_to be_building }
    end

    context 'the payload build has errored' do
      let(:fixture_file) { "failure.json" }
      it { is_expected.not_to be_building }
    end

    context 'the payload build has finished running' do
      let(:fixture_file) { "success.json" }
      it { is_expected.not_to be_building }
    end

    context 'the payload build has not finished running' do
      let(:fixture_file) { "building.json" }
      it { is_expected.to be_building }
    end

    context 'the payload build has not started running' do
      let(:fixture_file) { "created.json" }
      it { is_expected.to be_building }
    end
  end
end
