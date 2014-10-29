require 'spec_helper'

describe TeamCityJsonPayload do

  let(:status_content) { TeamCityJsonExample.new(example_file).read }
  let(:payload) { TeamCityJsonPayload.new.tap { |p| p.remote_addr = "localhost" } }
  let(:converted_content) { payload.convert_content!(status_content).first }
  let(:example_file) { "success.txt" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'when content is valid' do
      let(:expected_content) { double }
      before do
        allow(JSON).to receive(:parse).and_return(expected_content)
      end

      it { is_expected.to eq([expected_content]) }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        expect {subject}.to raise_error Payload::InvalidContentException
        expect(payload.processable).to be false
        expect(payload.build_processable).to be false
      end
    end
  end

  describe "#status_content" do
    context "invalid JSON" do
      it "should log erros" do
        expect(payload).to receive(:log_error)
        payload.status_content = "non json content"
      end
    end
  end

  describe '#building?' do

    subject do
      payload.status_content = status_content
      payload.building?
    end

    context 'should be building when build result is "running" and notify type is "started"' do
      let(:example_file) { 'building.txt' }

      it { is_expected.to be true }
    end

    context 'should not be building when build result is not "running"' do
      let(:example_file) { 'building_not_running.txt'}

      it { is_expected.to be false }
    end

    context 'should not be building when notify type is not "started"' do
      let(:example_file) { 'building_not_started.txt'}

      it { is_expected.to be false }
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(converted_content) }

    context 'the payload contains a successful build status' do
      it { is_expected.to be true }
    end

    context 'the payload contains a failure build status' do
      let(:example_file) { "failure.txt" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(converted_content) }

    context 'the build has finished' do
      it { is_expected.to be true }
    end

    context 'the build has not finished' do
      let(:example_file) { "building.txt" }
      it { is_expected.to be false }
    end
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(converted_content) }
    it { is_expected.to eq('1') }
  end

  describe '#parse_url' do
    context 'using the old success format' do
      it 'parses the response and builds a url' do
        return_value = payload.parse_url(converted_content)
        expect(payload.parsed_url).to eql("http://localhost:8111/viewType.html?buildTypeId=bt2")
        expect(return_value).to eql("http://localhost:8111/viewLog.html?buildId=1&tab=buildResultsDiv&buildTypeId=bt2")
      end
    end

    context 'using the newer success format' do
      let(:example_file) { "success_alternate.txt" }

      it 'parses the response for a buildStatusUrl attribute' do
        payload.parse_url(converted_content)
        expect(payload.parsed_url).to eql("http://localhost:8111/viewLog.html?buildTypeId=Foo_Bar&buildId=7")
      end
    end
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(converted_content) }
    it { is_expected.to be_an_instance_of(Time) }
  end
end
