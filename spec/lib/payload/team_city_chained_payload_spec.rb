require 'spec_helper'

describe TeamCityChainedPayload do
  let(:project) { FactoryGirl.create(:team_city_chained_project) }
  let(:children) { [] }
  let(:payload) { TeamCityChainedXmlPayload.new(project) }
  before do
    project.stub(:children).and_return(children)
  end

  subject do
    PayloadProcessor.new(project, payload).process
    project.reload
  end

  describe "project status" do
    context "when not currently building" do
      before { payload.status_content = content }

      let(:content) {
        <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="#{status}" webUrl="/1" startDate="#{5.minutes.ago}" />
          </builds>
        XML
      }

      context "when build was successful" do
        let(:status) { 'SUCCESS' }
        it { should be_green }
      end

      context "when build had failed" do
        let(:status) { 'FAILURE' }
        it { should be_red }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        content = <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="SUCCESS" webUrl="/1" startDate="#{5.minutes.ago}" />
          </builds>
        XML
        payload = TeamCityChainedXmlPayload.new(project)
        payload.status_content = content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        content = <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
          </builds>
        XML
        payload = TeamCityChainedXmlPayload.new(project)
        payload.status_content = content
        PayloadProcessor.new(project,payload).process
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        content = <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" startDate="#{5.minutes.ago}" />
          </builds>
        XML
        payload = TeamCityChainedXmlPayload.new(project)
        payload.status_content = content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        content = <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
          </builds>
        XML
        payload = TeamCityChainedXmlPayload.new(project)
        payload.status_content = content
        PayloadProcessor.new(project,payload).process
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end
  end

  describe "parse_building_status" do
    let(:content) {
      <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1"
      #{project_is_running ? 'running="true"' : nil}
            />
          </builds>
      XML
    }
    before { payload.status_content = content }

    context "with a valid response that the project is building" do
      let(:children) { [ double('child project', red?: true, last_build_time: Time.now) ] }
      let(:project_is_running) { true }
      it { should be_building }
      children.each {|child| child.should_not_receive(:building?) }
    end

    context "with a valid response that the project is not building" do
      let(:project_is_running) { false }

      context "and with no children" do
        it { should_not be_building }
      end

      context "and with children" do
        context "which are building" do
          let(:children) { [ double('child_project', building?: true, red?: true, last_build_time: Time.now) ] }
          it { should be_building }
        end

        context "which are not building" do
          let(:children) { [ double('child_project', building?: false, red?: true, last_build_time: Time.now) ] }
          it { should_not be_building }
        end
      end
    end

    context "with an invalid response" do
      let(:content) { "<foo><bar>baz</bar></foo>" }
      before { payload.status_content = content }

      it { should_not be_building }

      it "should not create a status" do
        expect { subject }.not_to change(ProjectStatus, :count)
      end
    end
  end
end
