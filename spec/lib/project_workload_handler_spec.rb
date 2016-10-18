require 'spec_helper'

describe ProjectWorkloadHandler do

  let(:log) { PayloadLogEntry.new }
  let(:payload_processor) { double(PayloadProcessor) }
  let(:project) { double.as_null_object }
  let(:job_results) { double(:job_results) }
  let(:payload) { double(Payload) }
  subject { ProjectWorkloadHandler.new(project, payload_processor: payload_processor) }

  before do
    allow(project).to receive(:fetch_payload).and_return(payload)
    allow(payload).to receive(:status_content=)
    allow(payload).to receive(:build_status_content=)
    allow(payload_processor).to receive(:process_payload).with({project: project, payload: payload}).and_return(log)
  end

  describe '#workload_complete' do
    let(:project) { create(:project) }
    let(:job_results) { double.as_null_object }

    it 'should process the provided status content' do
      expect(payload).to receive(:status_content=).with('feed content')
      expect(payload).to receive(:build_status_content=).with('build content')
      expect(payload_processor).to receive(:process_payload).with({project: project, payload: payload})

      subject.workload_complete({feed_url: 'feed content', build_status_url: 'build content'})
    end

    it 'sets the project to online' do
      subject.workload_complete(job_results)
      expect(project.online).to eq(true)
    end

    describe 'creating a log entry' do
      before do
        allow(payload_processor).to receive(:process_payload) { PayloadLogEntry.new(status: 'success') }
      end

      it 'creates a payload_log_entry' do
        expect {
          subject.workload_complete(job_results)
        }.to change(project.payload_log_entries, :count).by(1)

        expect(project.payload_log_entries.last.status).to eq('success')
      end

      it 'sets the method to Polling' do
        subject.workload_complete(job_results)
        expect(project.payload_log_entries.last.update_method).to eq('Polling')
      end
    end

    context 'if something goes wrong' do
      before do
        project.update!(online: true)
        project.name = nil
        expect(project).not_to be_valid
      end

      it 'creates an error log (in addition to the original log entry)' do
        expect {
          subject.workload_complete(job_results)
        }.to change(project.payload_log_entries, :count).by(2)

        expect(project.payload_log_entries.where(error_type: 'ActiveRecord::RecordInvalid')).to be_present
      end

      it 'sets the project to offline' do
        subject.workload_complete(job_results)

        expect(project.reload.online).to eq(false)
      end
    end
  end

  describe '#workload_failed' do
    let(:error) { double }

    before do
      allow(error).to receive(:backtrace).and_return(['backtrace', 'more'])
    end

    after { subject.workload_failed(error) }

    it 'should add a log entry' do
      allow(error).to receive(:message).and_return('message')
      expect(project.payload_log_entries).to receive(:build)
                                                 .with(error_type: 'RSpec::Mocks::Double', error_text: 'message', update_method: 'Polling', status: 'failed', backtrace: "message\nbacktrace\nmore")
    end

    it 'should not call message on a failure when passed a String instead of an Exception' do
      expect(project.payload_log_entries).to receive(:build)
                                                 .with(error_type: 'RSpec::Mocks::Double', error_text: '', update_method: 'Polling', status: 'failed', backtrace: "\nbacktrace\nmore")
    end

    it 'should set building to false' do
      expect(project).to receive(:building=).with(false)
    end

    it 'should set online to false' do
      expect(project).to receive(:online=).with(false)
    end

    it 'should save the project' do
      expect(project).to receive :save!
    end
  end
end
