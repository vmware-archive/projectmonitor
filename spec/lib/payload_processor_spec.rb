require 'spec_helper'

describe PayloadProcessor do
  let(:project) { double(Project).as_null_object }
  let(:payload) { double(Payload).as_null_object }
  let(:status) { double(ProjectStatus).as_null_object }
  let(:project_status_updater) { double }
  let(:processor) { PayloadProcessor.new(project_status_updater: project_status_updater) }

  describe "#process" do
    context "when the payload has processable statuses" do
      before do
        allow(payload).to receive(:status_is_processable?).and_return(true)
        allow(payload).to receive(:each_status).and_yield(status)
      end

      it "does nothing if build_branch_matches is false" do
        allow(payload).to receive(:build_branch_matches).and_return(false)
        expect(project).to_not receive(:online=)
        processor.process_payload project: project, payload: payload
      end

      it "defaults to using master branch when no build_branch is specified" do
        allow(project).to receive(:build_branch).and_return nil
        expect(payload).to receive(:build_branch_matches).with 'master'
        expect(payload).to_not receive(:build_branch_matches).with nil
        processor.process_payload project: project, payload: payload
      end

      it "sets the project as online" do
        expect(project).to receive(:online=).with(true)
        processor.process_payload(project: project, payload: payload)
      end

      it "initializes a ProjectStatus for every payload status" do
        status = double(ProjectStatus, valid?: true).as_null_object
        allow(project).to receive(:has_status?).and_return(false)
        allow(payload).to receive(:each_status).and_yield(status).and_yield(status)

        expect(project_status_updater).to receive(:update_project).twice

        processor.process_payload(project: project, payload: payload)
      end

      it "add a status to the project if the project does not have a matching status" do
        allow(project).to receive(:has_status?).and_return(false)
        expect(project_status_updater).to receive(:update_project).with(project, status)
        processor.process_payload(project: project, payload: payload)
      end

      it "does not add the status to the project if a matching status exists" do
        allow(project).to receive(:has_status?).and_return(true)
        expect(project_status_updater).not_to receive(:update_project)
        processor.process_payload(project: project, payload: payload)
      end

      context "with an invalid status" do
        let(:project) { create(:project) }
        let(:status) { build(:project_status, success: nil) }
        before {
          allow(payload).to receive(:building?).and_return(false)
          expect(status).to be_invalid
        }

        it "does not add the status to the project if it is invalid" do
          expect { processor.process_payload(project: project, payload: payload) }.not_to change(project.statuses, :count)
        end

        it "logs an error to the project if the status is invalid" do
          allow(payload).to receive(:status_content).and_return("some crazy response")
          processor.process_payload(project: project, payload: payload)

          error_entry = project.payload_log_entries.find { |entry| entry.error_type == "Status Invalid" }
          expect(error_entry).to be_present
          expect(error_entry.error_text).to eq <<ERROR
Payload returned an invalid status: #{status.inspect}
  Errors: Success is not included in the list
  Payload: #{payload.inspect}
ERROR
        end
      end
    end

    context "when the payload statuses are not processable" do
      before { allow(payload).to receive(:status_is_processable?).and_return(false) }

      it "skips accessing each status" do
        expect(payload).not_to receive(:each_status)
        processor.process_payload(project: project, payload: payload)
      end

      it "sets the project as offline" do
        expect(project).to receive(:online=).with(false)
        processor.process_payload(project: project, payload: payload)
      end
    end

    context "when payload has a processable building_status" do
      before { allow(payload).to receive(:build_status_is_processable?).and_return(true) }

      it "sets the project building status to that of the payload" do
        building = double(:boolean)
        allow(payload).to receive(:building?).and_return(building)

        expect(project).to receive(:building=).with(building)

        processor.process_payload(project: project, payload: payload)
      end
    end

    context "when the payload build_status is not processable" do
      before { allow(payload).to receive(:build_status_is_processable?).and_return(false) }

      it "sets the project as not building" do
        expect(project).to receive(:building=).with(false)
        processor.process_payload(project: project, payload: payload)
      end
    end

  end

  describe "parse_url" do
    before do
      allow(payload).to receive(:status_is_processable?).and_return(true)
      allow(payload).to receive(:parsed_url) { 'http://www.example.com' }
    end

    it "should set the project parsed_url" do
      expect(project).to receive(:parsed_url=).with('http://www.example.com')
      processor.process_payload(project: project, payload: payload)
    end
  end
end
