require 'spec_helper'

describe ProjectWorkloadHandler do

  let(:handler) { ProjectWorkloadHandler.new(project) }
  let(:project) { double.as_null_object }

  let(:workload) { double }

  describe '#workload_created' do
    after { handler.workload_created(workload) }

    before { allow(workload).to receive(:add_job) }

    it 'should add the feed_url' do
      expect(workload).to receive(:add_job).with(:feed_url, project.feed_url)
    end

    it 'should add the build_status_url' do
      expect(workload).to receive(:add_job).with(:build_status_url, project.build_status_url)
    end
  end

  describe '#workload_complete' do
    let(:project) { create(:project) }
    let(:workload) { double.as_null_object }

    it 'should set status content' do
      expect(workload).to receive(:recall).with(:feed_url)
      handler.workload_complete(workload)
    end

    it 'should set build status content' do
      expect(workload).to receive(:recall).with(:build_status_url)
      handler.workload_complete(workload)
    end

    describe "creating a log entry" do
      it "creates a payload_log_entry" do
        expect {
          handler.workload_complete(workload)
        }.to change(project.payload_log_entries, :count).by(1)
      end

      it "sets the method to 'Polling'" do
        handler.workload_complete(workload)
        expect(project.payload_log_entries.last.update_method).to eq("Polling")
      end
    end

    it "sets the project to online" do
      handler.workload_complete(workload)

      expect(project.online).to eq(true)
    end

    context "if something goes wrong" do
      before do
        project.update!(online: true)
        project.name = nil
        expect(project).not_to be_valid
      end

      it "creates an error log (in addition to the original log entry)" do
        expect {
          handler.workload_complete(workload)
        }.to change(project.payload_log_entries, :count).by(2)

        expect(project.payload_log_entries.where(error_type: "ActiveRecord::RecordInvalid")).to be_present
      end

      it "sets the project to offline" do
        handler.workload_complete(workload)

        expect(project.reload.online).to eq(false)
      end
    end
  end

  describe '#workload_failed' do
    let(:error) { double }

    before do
      allow(error).to receive(:backtrace).and_return(["backtrace", "more"])
    end

    after { handler.workload_failed(workload, error) }

    it 'should add a log entry' do
      allow(error).to receive(:message).and_return("message")
      expect(project.payload_log_entries).to receive(:build)
      .with(error_type: "RSpec::Mocks::Double", error_text: "message", update_method: "Polling", status: "failed", backtrace: "message\nbacktrace\nmore")
    end

    it 'should not call message on a failure when passed a String instead of an Exception' do
      expect(project.payload_log_entries).to receive(:build)
      .with(error_type: "RSpec::Mocks::Double", error_text: "", update_method: "Polling", status: "failed", backtrace: "\nbacktrace\nmore")
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
