require 'spec_helper'

describe CruiseControlPayloadProcessor do
  let(:project) do
    FactoryGirl.create(
      :cruise_control_project,
      cruise_control_rss_feed_url: "http://foo.bar.com:3434/projects/Socialitis.rss")
  end
  let(:payload) { [CCRssExample.new(rss).read, nil] }

  subject do
    ProjectPayloadProcessor.new(project, payload).perform
    project.reload
  end

  describe "project status" do
    context "when not currently building" do
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
      it "remains green when existing status is green" do
        payload = [CCRssExample.new("success.rss").read, nil]
        CruiseControlPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = [nil, BuildingStatusExample.new("socialitis_building.xml").read]
        CruiseControlPayloadProcessor.new(project,payload).perform
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        payload = [CCRssExample.new("failure.rss").read, nil]
        CruiseControlPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = [nil, BuildingStatusExample.new("socialitis_building.xml").read]
        CruiseControlPayloadProcessor.new(project,payload).perform
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end


  end

  describe "building status" do
    let(:payload) { [nil, BuildingStatusExample.new(xml).read] }
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
    let!(:payload) { [example.read, nil] }
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
    let(:payload) { ["<foo><bar>baz</bar></foo>", nil] }
    it { should_not be_building }
    its(:latest_status) { should_not be_success }
  end
end
