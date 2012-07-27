require 'spec_helper'

describe TeamCityChainedXmlPayload do
  let(:project) { FactoryGirl.create(:team_city_chained_project) }
  let(:children) { [] }
  let(:payload) { TeamCityChainedXmlPayload.new(project) }
  before { project.stub(:children).and_return(children) }

  subject do
    PayloadProcessor.new(project, payload).process
    project.reload
  end

  def content_for(status, options={})
    <<-XML.strip_heredoc
      <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
      <builds count="1">
        <build id="1" number="1" status="#{status.upcase}" webUrl="/1" startDate="#{5.minutes.ago}" #{options.fetch(:building, false) ? "running=\"true\"" : ''}/>
      </builds>
    XML
  end

  describe "project status" do
    context "with no children" do
      context "and not currently building" do
        let(:content) { content_for(status) }
        before { payload.status_content = content }

        context "when build was successful" do
          let(:status) { 'SUCCESS' }
          it { should be_green }
        end

        context "when build had failed" do
          let(:status) { 'FAILURE' }
          it { should be_red }
        end
      end

      context "and currently building" do
        it "remains green when existing status is green" do
          payload.status_content = content_for("SUCCESS")
          PayloadProcessor.new(project,payload).process
          project.reload.should be_green

          payload.status_content = content_for("FAILURE", building: true)
          expect {
            PayloadProcessor.new(project,payload).process
          }.not_to change{ project.statuses.count }
          project.reload.should be_green
        end

        it "remains red when existing status is red" do
          payload.status_content = content_for("FAILURE")
          PayloadProcessor.new(project,payload).process
          project.reload.should be_red

          payload.status_content = content_for("SUCCESS", building: true)
          expect {
            PayloadProcessor.new(project,payload).process
          }.not_to change{ project.statuses.count }
          project.reload.should be_red
        end
      end
    end
  end

  describe "payload building status" do
    let(:content) { content_for("FAILURE", building: project_is_building) }
    before { payload.status_content = content }

    context "when the project is building" do
      let(:project_is_building) { true }

      context "and the project has children" do
        let(:children) { [double('child project', red?: true, last_build_time: Time.now)] }

        it "does not ask the children if they are building" do
          children.each {|child| child.should_not_receive(:building?) }
          subject.should be_building
        end
      end
    end

    context "when the project is not building" do
      let(:project_is_building) { false }

      context "and the project has no children" do
        it { should_not be_building }
      end

      context "and the project has children" do
        context "which are building" do
          let(:children) { [double('child_project', building?: true, red?: true, last_build_time: Time.now)] }
          it { should be_building }
        end

        context "which are not building" do
          let(:children) { [double('child_project', building?: false, red?: true, last_build_time: Time.now)] }
          it { should_not be_building }
        end
      end
    end

    context "with an invalid response" do
      let(:content) { "<foo><bar>baz</bar></foo>" }

      it { should_not be_building }

      it "does not create a status" do
        expect { subject }.not_to change(ProjectStatus, :count)
      end
    end
  end
end
