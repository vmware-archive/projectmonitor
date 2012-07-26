require 'spec_helper'

describe PayloadProcessor do
  let(:project) { double(Project).as_null_object }
  let(:payload) { double(Payload).as_null_object }
  let(:status) { double(ProjectStatus).as_null_object }
  let(:processor) { PayloadProcessor.new(project, payload) }

  describe "#process" do
    context "when the payload has processable statuses" do
      before do
        payload.stub(status_is_processable?: true)
        payload.stub(:each_status).and_yield(status)
      end

      it "sets the project as online" do
        project.should_receive(:online!)
        processor.process
      end

      it "initializes a ProjectStatus for every payload status" do
        status = double(ProjectStatus, valid?: true).as_null_object
        project.stub(has_status?: false)
        payload.stub(:each_status).and_yield(status).and_yield(status)

        project.statuses.should_receive(:"<<").twice

        processor.process
      end

      context "and ProjectStatus is valid" do
        let(:status) { double(ProjectStatus, valid?: true) }
        before { ProjectStatus.stub(new: status) }

        it "add a status to the project if the project does not have a matching status" do
          project.stub(has_status?: false)
          project.statuses.should_receive(:"<<").with(status)
          processor.process
        end

        it "does not add the status to the project if a matching status exists" do
          project.stub(has_status?: true)
          project.statuses.should_not_receive(:"<<")
          processor.process
        end
      end

      context "and ProjectStatus is not valid" do
        let(:status) { double(ProjectStatus, valid?: false) }
        before { ProjectStatus.stub(new: status) }

        it "does not the status to the project" do
          project.stub(has_status?: false)
          project.statuses.should_not_receive(:"<<")
          processor.process
        end
      end
    end

    context "when the payload statuses are not processable" do
      before { payload.stub(status_is_processable?: false) }

      it "skips accessing each status" do
        payload.should_not_receive(:each_status)
        processor.process
      end

      it "sets the project as offline" do
        project.should_receive(:offline!)
        processor.process
      end
    end

    context "when payload has a processable building_status" do
      before { payload.stub(build_status_is_processable?: true) }

      it "sets the project building status to that of the payload" do
        building = double(Boolean)
        payload.stub(building?: building)

        project.should_receive(:update_attributes!).with(building: building)

        processor.process
      end
    end

    context "when the payload build_status is not processable" do
      before { payload.stub(build_status_is_processable?: false) }

      it "sets the project as not building" do
        project.should_receive(:not_building!)
        processor.process
      end
    end
  end
end
