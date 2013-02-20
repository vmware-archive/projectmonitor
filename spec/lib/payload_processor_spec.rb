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
        project.should_receive(:online=).with(true)
        processor.process
      end

      it "initializes a ProjectStatus for every payload status" do
        status = double(ProjectStatus, valid?: true).as_null_object
        project.stub(has_status?: false)
        payload.stub(:each_status).and_yield(status).and_yield(status)

        project.statuses.should_receive(:push).twice

        processor.process
      end

      it "add a status to the project if the project does not have a matching status" do
        project.stub(has_status?: false)
        project.statuses.should_receive(:push).with(status)
        processor.process
      end

      it "does not add the status to the project if a matching status exists" do
        project.stub(has_status?: true)
        project.statuses.should_not_receive(:push)
        processor.process
      end
    end

    context "when the payload statuses are not processable" do
      before { payload.stub(status_is_processable?: false) }

      it "skips accessing each status" do
        payload.should_not_receive(:each_status)
        processor.process
      end

      it "sets the project as offline" do
        project.should_receive(:online=).with(false)
        processor.process
      end
    end

    context "when payload has a processable building_status" do
      before { payload.stub(build_status_is_processable?: true) }

      it "sets the project building status to that of the payload" do
        building = double(Boolean)
        payload.stub(building?: building)

        project.should_receive(:building=).with(building)

        processor.process
      end
    end

    context "when the payload build_status is not processable" do
      before { payload.stub(build_status_is_processable?: false) }

      it "sets the project as not building" do
        project.should_receive(:building=).with(false)
        processor.process
      end
    end

  end

  describe "parse_url" do
    before do
      payload.stub(:status_is_processable?) { true }
      payload.stub(:parsed_url) { 'http://www.example.com' }
    end

    it "should set the project parsed_url" do
      project.should_receive(:parsed_url=).with('http://www.example.com')
      processor.process
    end
  end
end
