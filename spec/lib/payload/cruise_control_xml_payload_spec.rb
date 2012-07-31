require 'spec_helper'

describe CruiseControlXmlPayload do
  let(:project) { FactoryGirl.create(:cruise_control_project, cruise_control_rss_feed_url: "http://foo.bar.com:3434/projects/Socialitis.rss") }

  subject do
    PayloadProcessor.new(project, payload).process
    project
  end

  describe "project status" do
    context "when not currently building" do
      let(:status_content) { CCRssExample.new(rss).read }
      let(:payload) { CruiseControlXmlPayload.new(project.name) }
      before { payload.status_content = status_content }

      context "when build was successful" do
        let(:rss) { "success.rss" }
        it { should be_green }
      end

      context "when build had failed" do
        let(:rss) { "failure.rss" }
        it { should be_red }
      end
    end

    context "when building" do
      let(:payload) { CruiseControlXmlPayload.new(project.name) }

      it "remains green when existing status is green" do
        status_content = CCRssExample.new("success.rss").read
        payload.status_content = status_content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        build_content = BuildingStatusExample.new("socialitis_building.xml").read
        payload.build_status_content = build_content
        PayloadProcessor.new(project,payload).process
        project.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        status_content = CCRssExample.new("failure.rss").read
        payload.status_content = status_content
        PayloadProcessor.new(project,payload).process
        statuses = project.statuses
        build_content = BuildingStatusExample.new("socialitis_building.xml").read
        payload.build_status_content = build_content
        PayloadProcessor.new(project,payload).process
        project.should be_red
        project.statuses.should == statuses
      end
    end


  end

  describe "building status" do
    let(:build_content) { BuildingStatusExample.new(xml).read }
    let(:payload) { CruiseControlXmlPayload.new('Socialitis') }
    before { payload.build_status_content = build_content }

    context "when building" do
      let(:xml) { "socialitis_building.xml" }
      it { should be_building }
    end

    context "when not building" do
      let(:xml) { "socialitis_not_building.xml" }
      it { should_not be_building }
    end
  end

  describe "saving data" do
    let(:example) { CCRssExample.new(xml) }
    let(:status_content) { example.read }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }
    before { payload.status_content = status_content }

    describe "when build was successful" do
      let(:xml) { "success.rss" }

      its(:latest_status) { should be_success }

      it "return the link to the checkin" do
        subject.latest_status.url.should == CCRssExample.new("success.rss").xpath_content("/rss/channel/item/link")
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(CCRssExample.new("success.rss").xpath_content("/rss/channel/item/pubDate"))
      end
    end

    describe "when build failed" do
      let(:xml) { "failure.rss" }

      its(:latest_status) { should_not be_success }

      it "return the link to the checkin" do
        subject.latest_status.url.should == CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/link")
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/pubDate"))
      end
    end
  end

  describe "with invalid xml" do
    let(:status_content) { "<foo><bar>baz</bar></foo>" }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }
    before { payload.status_content = status_content }

    it { should_not be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
