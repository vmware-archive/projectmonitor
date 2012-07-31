require 'spec_helper'
describe LegacyTeamCityXmlPayload do
  let(:project) { FactoryGirl.create(:team_city_project) }
  let(:content) { TeamcityCradiatorXmlExample.new(xml).read }
  let(:payload) { LegacyTeamCityXmlPayload.new }

  subject do
    PayloadProcessor.new(project, payload).process
    project
  end

  describe "project status" do
    context "when not currently building" do
      before { payload.status_content = content }

      context "when latest build is successful" do
        let(:xml) { "success.xml" }
        it { should be_green }

        it "doesn't add a duplicate of the existing status" do
          latest_status = subject.latest_status
          statuses = project.statuses
          subject.latest_status.should == latest_status
          project.statuses.should == statuses
        end
      end

      context "when latest build has failed" do
        let(:xml) { "failure.xml" }
        it { should be_red }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        status_content = TeamcityCradiatorXmlExample.new("success.xml").read
        payload.status_content = status_content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        build_content = BuildingStatusExample.new("team_city_building.xml").read
        payload.build_status_content = build_content
        PayloadProcessor.new(project,payload).process
        project.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        status_content = TeamcityCradiatorXmlExample.new("failure.xml").read
        payload.status_content = status_content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        build_content = BuildingStatusExample.new("team_city_building.xml").read
        payload.build_status_content = build_content
        PayloadProcessor.new(project,payload).process
        project.should be_red
        project.statuses.should == statuses
      end
    end
  end

  describe "saving data" do
    let(:example) { TeamcityCradiatorXmlExample.new(xml) }
    let(:content) { example.read }

    before { payload.status_content = content }

    describe "when build was successful" do
      let(:xml)  { "success.xml" }

      its(:latest_status) { should be_success }

      it "should return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("Build").attribute("webUrl").value
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should ==  Time.parse(example.first_css("Build").attribute("lastBuildTime").content)
      end
    end

    describe "when build failed" do
      let(:xml) { "failure.xml" }

      its(:latest_status) { should_not be_success }

      it "should return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("Build").attribute('webUrl').value
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.first_css("Build").attribute("lastBuildTime").value)
      end
    end
  end

  describe "building status" do
    let(:build_content) { BuildingStatusExample.new(xml).read }
    let(:xml) { "team_city_building.xml" }
    before { payload.build_status_content = build_content }

    it { should be_building }

    it "should set building to false on the project when it is not building" do
      subject.should be_building
      build_content = BuildingStatusExample.new("team_city_not_building.xml").read
      payload.build_status_content = build_content
      PayloadProcessor.new(project,payload).process
      project.should_not be_building
    end
  end

  describe "with invalid xml" do
    let(:content) { "<foo><bar>baz</bar></foo>" }
    before { payload.status_content = content }

    it { should_not be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
