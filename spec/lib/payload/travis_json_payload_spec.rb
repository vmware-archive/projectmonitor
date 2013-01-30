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
      before do
        Rack::Utils.stub(:parse_nested_query).and_return({})
      end

      it 'provides an empty string to JSON.parse' do
        JSON.should_receive(:parse).with('')
        TravisJsonPayload.new.convert_webhook_content!(status_content)
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
    it { should == Time.utc(2013, 1, 22, 21, 20, 56) }
  end
end
