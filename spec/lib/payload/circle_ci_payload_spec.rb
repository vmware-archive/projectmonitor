require 'spec_helper'

describe CircleCiPayload do

  let(:status_content) { CircleCiExample.new(json).read }
  let(:payload) { CircleCiPayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:json) { "success.json" }

  let(:status_content_history) { CircleCiExample.new(json_history).read }
  let(:json_history) { "success_history.json" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'and status is pending' do
      let(:json) { "pending.json" }
      let(:content) { {'status' => 'running'} }

      it 'should be marked as unprocessable' do
        payload.content_ready?(content).should be_false
      end
    end

    context 'and content is valid' do
      let(:expected_content) { double(:content, key?: false) }
      before do
        JSON.stub(:parse).and_return(expected_content)
      end

      it{ should == [expected_content] }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        JSON.stub(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        payload.processable.should be_false
      end

      context "bad XML data" do
        let(:wrong_status_content) { "some non xml content" }
        it "should log errors" do
          payload.should_receive("log_error")
          payload.status_content = wrong_status_content
        end
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload contains a successful build status' do
      it { should be_true }
    end

    context 'the payload contains a failure build status' do
      let(:json) { "failure.json" }
      it { should be_false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(content) }

    context 'the build has not finished' do
      let(:json) { "pending.json" }
      it { should be_false }
    end

    context 'the build has finished' do
      it { should be_true }
    end
  end

  describe '#parse_url' do
    subject { payload.parse_url(content) }

    it { should == 'https://circleci.com/gh/auser/project/172' }
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { should == 172 }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content).round }
    it { should == Time.utc(2013, 10, 15, 8, 47, 30) }
  end

end
