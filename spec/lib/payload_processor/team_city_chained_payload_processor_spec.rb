require 'spec_helper'

describe TeamCityChainedPayloadProcessor do
  let(:project) { TeamCityChainedProject.create(:name => "my_teamcity_project", :feed_url => "http://foo.bar.com:3434/app/rest/builds?locator=running:all,buildType:(id:bt3)" ) }
  let(:children) { [] }
  before { project.stub(:children).and_return(children) }

  subject do
    ProjectPayloadProcessor.new(project, payload).perform
    project.reload
  end

  describe "project status" do
    context "when not currently building" do
      let(:payload) {
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
        payload = <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="SUCCESS" webUrl="/1" startDate="#{5.minutes.ago}" />
          </builds>
        XML
        TeamCityChainedPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
          </builds>
        XML
        TeamCityChainedPayloadProcessor.new(project,payload).perform
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        payload = <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" startDate="#{5.minutes.ago}" />
          </builds>
        XML
        TeamCityChainedPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
          </builds>
        XML
        TeamCityChainedPayloadProcessor.new(project,payload).perform
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end
  end

  describe "parse_building_status" do
    let(:payload) {
      <<-XML
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1"
      #{project_is_running ? 'running="true"' : nil}
            />
          </builds>
      XML
    }

    context "with a valid response that the project is building" do
      let(:children) { [ double('child project') ] }
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
          let(:children) { [ double('child_project', building?: true) ] }
          it { should be_building }
        end
        context "which are not building" do
          let(:children) { [ double('child_project', building?: false) ] }
          it { should_not be_building }
        end
      end
    end

    context "with an invalid response" do
      let(:payload) { "<foo><bar>baz</bar></foo>" }
      it { should_not be_building }
    end
  end
end
