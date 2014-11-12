RSpec.shared_examples "a JSON payload" do

  describe "#status_content=" do
    context "with invalid status content" do
      it "should log the error" do
        expect(payload).to receive(:log_error)
        payload.status_content = 'invalid string'
      end

      it 'should be marked as unprocessable' do
        allow(JSON).to receive(:parse).and_raise(JSON::ParserError)
        expect {payload.convert_content!(fixture_content)}.to raise_error Payload::InvalidContentException
        expect(payload.processable).to be false
        expect(payload.build_processable).to be false
      end
    end
  end

  describe "#processable" do
    context 'with invalid status content' do
      subject { payload.processable }
      before(:each) { payload.status_content = fixture_content }

      context 'with empty string' do
        let(:fixture_content) { '' }
        it { is_expected.to be false }
      end

      context 'with unparseable JSON' do
        let(:fixture_content) { 'I am not valid JSON, now am I?' }
        it { is_expected.to be false }
      end

      context 'with unexpected type' do
        let(:fixture_content) { 1 }
        it { is_expected.to be false }
      end
    end
  end

  describe "#convert_content!" do
    subject { payload.convert_content!(fixture_content) }

    context "with valid content" do
      it "should return an array with at least one value" do
        expect(subject.class).to eq Array
        expect(subject.length).to be >= 1
      end
    end
  end

  describe '#parse_success' do
    subject { payload.parse_success(converted_content) }

    context 'with a successful build do' do
      it { is_expected.to be true }
    end

    context 'with an unsuccessful build' do
      let(:fixture_file) { 'failure.json' }
      it { is_expected.to be false }
    end
  end

  describe '#content_ready?' do
    subject { payload.content_ready?(converted_content) }

    context 'build has finished' do
      it { is_expected.to be true }
    end

    context 'build has not finished' do
      let(:fixture_file) { 'building.json' }
      it { is_expected.to be false }
    end
  end

  describe '#building?' do
    subject { payload }
    before(:each)  { payload.build_status_content = fixture_content }

    context 'when building' do
      let(:fixture_file) { 'building.json' }
      it { is_expected.to be_building }
    end

    context 'when not building' do
      it { is_expected.not_to be_building }
    end
  end

end
