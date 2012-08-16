require 'spec_helper'

describe JenkinsJsonPayload do

  let(:status_content) { JenkinsJsonExample.new(example_file).read }
  let(:payload) { JenkinsJsonPayload.new }
  let(:converted_content) { payload.convert_content!(status_content).first }
  let(:example_file) { "success.txt" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'when content is valid' do
      let(:expected_content) { double }
      before do
        JSON.stub(:parse).and_return(expected_content)
      end

      it { should == [expected_content] }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        JSON.stub(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        subject
        payload.processable.should be_false
        payload.build_processable.should be_false
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(converted_content) }

    context 'the payload contains a successful build status' do
      it { should be_true }
    end

    context 'the payload contains a failure build status' do
      let(:example_file) { "failure.txt" }
      it { should be_false }
    end
  end

  describe '#parse_url' do
    subject { payload.parse_url(converted_content) }

    it { should == 'job/projectmonitor_ci_test/7/' }
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(converted_content) }
    it { should == 7 }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(converted_content) }
    it { should be_an_instance_of(Time) }
  end
end
