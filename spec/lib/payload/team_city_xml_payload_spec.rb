require 'spec_helper'

describe TeamCityXmlPayload do
  let(:project) { FactoryGirl.create(:team_city_rest_project) }
  let(:payload) { TeamCityXmlPayload.new.tap{|p|p.status_content = content} }

  describe '.process' do
    subject do
      PayloadProcessor.new(project, payload).process
      project
    end

    describe "project status" do
      context "when not currently building" do
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
          payload = TeamCityXmlPayload.new
          payload.status_content = content
          PayloadProcessor.new(project,payload).process
          statuses = project.statuses
          content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
            </builds>
          XML
          payload.status_content = content
          PayloadProcessor.new(project,payload).process
          project.should be_green
          project.statuses.should == statuses
        end

        it "remains red when existing status is red" do
          content = <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="FAILURE" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
          XML
          payload = TeamCityXmlPayload.new
          payload.status_content = content
          PayloadProcessor.new(project,payload).process
          statuses = project.statuses
          content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="FAILURE" webUrl="/1" running="true"/>
            </builds>
          XML
          payload = TeamCityXmlPayload.new
          payload.status_content = content
          PayloadProcessor.new(project,payload).process
          project.should be_red
          project.statuses.should == statuses
        end
      end
    end

    describe "building status" do
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

      context "with a valid response that the project is building" do
        let(:project_is_running) { true }
        it { should be_building }
      end

      context "with a valid response that the project is not building" do
        let(:project_is_running) { false }
        it { should_not be_building }
      end

      context "with an invalid response" do
        let(:content) { "<foo><bar>baz</bar></foo>" }
        it { should_not be_building }
      end
    end
  end

  describe "unknown status" do
    it "remains green when existing status is green" do
      project.online = true
      project.save!
      content = <<-XML.strip_heredoc
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="1" number="1" status="SUCCESS" webUrl="/1" startDate="#{5.minutes.ago}" />
            </builds>
      XML
      payload = TeamCityXmlPayload.new
      payload.status_content = content
      PayloadProcessor.new(project,payload).process

      project.reload.should be_green
      statuses = project.statuses

      content = <<-XML
            <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <builds count="1">
              <build id="2" number="2" status="UNKNOWN" webUrl="/2" />
            </builds>
      XML
      payload = TeamCityXmlPayload.new
      payload.status_content = content
      PayloadProcessor.new(project,payload).process

      project.reload.should be_green
      project.statuses.should == statuses
    end
  end

  describe '#each_child' do
    let(:content) { nil }
    before do
      payload.dependent_content = <<-XML.strip_heredoc
        <buildType id="bt5" name="Acceptance Deploy" href="/httpAuth/app/rest/buildTypes/id:bt5" webUrl="http://23.23.175.228:8111/viewType.html?buildTypeId=bt5" description="" paused="false">
          <project id="project2" name="Zephyr" href="/httpAuth/app/rest/projects/id:project2"/>
          <template id="btTemplate2" name="Zephyr" href="/httpAuth/app/rest/buildTypes/id:(template:btTemplate2)" projectName="Zephyr" projectId="project2"/>
          <snapshot-dependencies>
            <snapshot-dependency id="bt3" type="snapshot_dependency">
              <properties>
                <property name="run-build-if-dependency-failed" value="false"/>
                <property name="run-build-on-the-same-agent" value="false"/>
                <property name="source_buildTypeId" value="bt3"/>
                <property name="take-started-build-with-same-revisions" value="true"/>
                <property name="take-successful-builds-only" value="true"/>
              </properties>
            </snapshot-dependency>
          </snapshot-dependencies>
      XML
    end

    it 'should supply a child project with the appropriate id to a block' do
      child_project_id = nil
      payload.each_child(project) do |child_project|
        child_project_id = child_project.team_city_rest_build_type_id
      end
      child_project_id.should == 'bt3'
    end
  end
end
