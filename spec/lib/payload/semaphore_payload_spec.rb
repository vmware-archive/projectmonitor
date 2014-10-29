require 'spec_helper'

describe SemaphorePayload do

  let(:status_content) { SemaphoreExample.new(json).read }
  let(:payload) { SemaphorePayload.new.tap{|p| p.status_content = status_content} }
  let(:content) { payload.status_content.first }
  let(:json) { "success.json" }

  let(:status_content_history) { SemaphoreExample.new(json_history).read }
  let(:json_history) { "success_history.json" }

  describe '#convert_content!' do
    subject { payload.convert_content!(status_content) }

    context 'and status is pending' do
      let(:json) { "pending.json" }
      let(:content) { {'result' => 'pending'} }

      it 'should be marked as unprocessable' do
        expect(payload.content_ready?(content)).to be false
      end
    end

    context 'and content is valid' do
      let(:expected_content) { double(:content, key?: false) }
      before do
        allow(JSON).to receive(:parse).and_return(expected_content)
      end

      it{ is_expected.to eq([expected_content]) }
    end

    context 'when content is corrupt / badly encoded' do
      before do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
      end

      it 'should be marked as unprocessable' do
        expect(payload.processable).to be false
      end

      context "bad XML data" do
        let(:wrong_status_content) { "some non xml content" }
        it "should log errors" do
          expect(payload).to receive("log_error")
          payload.status_content = wrong_status_content
        end
      end
    end

    context 'when the project has a branch history url' do
      it "should return the builds array" do
        history_content = payload.convert_content!(status_content_history)
        expect(history_content.count).to eq(2)
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(content) }

    context 'the payload contains a successful build status' do
      it { is_expected.to be true }
    end

    context 'the payload contains a failure build status' do
      let(:json) { "failure.json" }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(content) }

    context 'the build has not finished' do
      let(:json) { "pending.json" }
      it { is_expected.to be false }
    end

    context 'the build has finished' do
      it { is_expected.to be true }
    end

    context 'the payload contains a build from a branch other than master' do
      let(:json) { "branch.json" }

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
    subject { payload.parse_url(content) }

    it { is_expected.to eq('https://semaphoreapp.com/projects/123/branches/456/builds/1') }
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(content) }
    it { is_expected.to eq(1) }
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(content) }
    it { is_expected.to eq(Time.new(2012, 8, 16, 2, 15, 34, "-07:00")) }
  end

end
