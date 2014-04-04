require 'spec_helper'

describe TravisJsonPayload do

  let(:status_content) { TravisExample.new(json).read }
  let(:payload) { TravisJsonPayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:json) { "success.json" }

  describe '#status_content' do
    subject { payload.status_content = status_content }

    context 'when content is valid' do
      let(:expected_content) { double(:expected_content, "[]" => nil) }
      before do
        JSON.stub(:parse).and_return(expected_content)
      end

      it 'should parse content' do
        subject
        payload.status_content.should == [expected_content]
      end
    end

    context 'when content is corrupt / badly encoded' do
      before do
        JSON.stub(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        payload.processable.should be_false
        payload.build_processable.should be_false
      end

      let(:wrong_status_content) { "some non xml content" }
      it "should log errors" do
        payload.should_receive("log_error")
        payload.status_content = wrong_status_content
      end
    end
  end

  describe '#convert_webhook_content!' do
    context 'when supplied with an empty payload' do
      let(:webhook_content) { TravisExample.new("webhook_success.txt").read }
      it 'provides an empty string to JSON.parse' do
        converted_content = TravisJsonPayload.new.convert_webhook_content!(webhook_content)
        converted_content.first['id'].should == 12150190
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload result is a success' do
      let(:json) { "success.json" }
      it { should be_true }
    end

    context 'the payload result is a failure' do
      let(:json) { "failure.json" }
      it { should be_false }
    end

    context 'the payload build has errored' do
      let(:json) { "errored.json" }
      it { should be_false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(content) }

    context 'the payload build has finished running' do
      let(:json) { "success.json" }
      it { should be_true }
    end

    context 'the payload build has not finished running' do
      let(:json) { "building.json" }
      it { should be_false }
    end

    context 'the payload build has not started running' do
      let(:json) { "created.json" }
      it { should be_false }
    end

    context 'the payload contains a build from a branch other than master' do
      let(:json) { "branch.json" }

      context 'and the branch has not been specified' do
        it { should be_false }
      end

      context 'and the branch has been specified' do
        before { payload.branch = 'staging' }

        it { should be_true }
      end
    end
    
    context 'the payload contains a build from pull request' do
      let(:json) { "pull_request.json" }
      it { should be_false }
    end
  end

  describe '#parse_url' do
    subject { payload }

    context "no slug exists" do
      it { payload.parse_url(content).should == "https://api.travis-ci.org/builds/4314974" }
    end

    context "a slug exists" do
      let!(:slug) { payload.slug = "account/project" }
      it { payload.parse_url(content).should == "https://travis-ci.org/account/project/builds/4314974" }
    end

  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { should == 4314974 }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content) }
    it { should == Time.utc(2013, 1, 22, 21, 16, 20) }
  end

  describe '#branch=' do
    subject { payload.branch }
    before { payload.branch = branch }

    context "when given a branch name" do
      let(:branch) { "staging" }
      it { should == branch }
    end

    context "when given an empty string" do
      let(:branch) { "" }
      it { should == "master" }
    end
  end

  describe '#building?' do
    before { payload.status_content = status_content }

    subject { payload }

    context 'the payload build has failed' do
      let(:json) { "errored.json" }
      it { should_not be_building }
    end

    context 'the payload build has errored' do
      let(:json) { "failure.json" }
      it { should_not be_building }
    end

    context 'the payload build has finished running' do
      let(:json) { "success.json" }
      it { should_not be_building }
    end

    context 'the payload build has not finished running' do
      let(:json) { "building.json" }
      it { should be_building }
    end

    context 'the payload build has not started running' do
      let(:json) { "created.json" }
      it { should be_building }
    end
  end
end
