require 'spec_helper'

describe ProjectWorkloadHandler do

  let(:handler) { ProjectWorkloadHandler.new(project) }
  let(:project) { double.as_null_object }

  let(:workload) { double }

  describe '#workload_created' do
    after { handler.workload_created(workload) }

    before { workload.stub(:add_job) }

    it 'should add the feed_url' do
      workload.should_receive(:add_job).with(:feed_url, project.feed_url)
    end

    it 'should add the build_status_url' do
      workload.should_receive(:add_job).with(:build_status_url, project.build_status_url)
    end
  end

  describe '#workload_complete' do
    let(:project) { create(:project) }
    let(:workload) { double.as_null_object }

    it 'should set status content' do
      workload.should_receive(:recall).with(:feed_url)
      handler.workload_complete(workload)
    end

    it 'should set build status content' do
      workload.should_receive(:recall).with(:build_status_url)
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
        project.payload_log_entries.last.update_method.should == "Polling"
      end
    end

    it "sets the project to online" do
      handler.workload_complete(workload)

      project.online.should == true
    end

    context "if something goes wrong" do
      before do
        project.update!(online: true)
        project.name = nil
        project.should_not be_valid
      end

      it "creates an error log (in addition to the original log entry)" do
        expect {
          handler.workload_complete(workload)
        }.to change(project.payload_log_entries, :count).by(2)

        project.payload_log_entries.where(:error_type => "ActiveRecord::RecordInvalid").should be_present
      end

      it "sets the project to offline" do
        handler.workload_complete(workload)

        project.reload.online.should == false
      end
    end
  end

  describe '#workload_failed' do
    let(:error) { double }

    before do
      error.stub(:backtrace).and_return(["backtrace", "more"])
    end

    after { handler.workload_failed(workload, error) }

    it 'should add a log entry' do
      error.stub(:message).and_return("message")
      project.payload_log_entries.should_receive(:build)
      .with(error_type: "RSpec::Mocks::Mock", error_text: "message", update_method: "Polling", status: "failed", :backtrace => "message\nbacktrace\nmore")
    end

    it 'should not call message on a failure when passed a String instead of an Exception' do
      project.payload_log_entries.should_receive(:build)
      .with(error_type: "RSpec::Mocks::Mock", error_text: "", update_method: "Polling", status: "failed", :backtrace => "\nbacktrace\nmore")
    end

    it 'should set building to false' do
      project.should_receive(:building=).with(false)
    end

    it 'should set online to false' do
      project.should_receive(:online=).with(false)
    end

    it 'should save the project' do
      project.should_receive :save!
    end
  end
end
