require 'spec_helper'

describe TravisPayloadProcessor do
  let(:project) { TravisProject.create(name: "foo", feed_url: "http://travis-ci.org/account/project/cc.xml") }
  let(:payload) { TravisExample.new(xml).read }

  subject do
    ProjectPayloadProcessor.new(project, payload).perform
    project.reload
  end

  describe "project status" do
    context "when not currently building" do

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
        payload = TravisExample.new("success.xml").read
        TravisPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = TravisExample.new("building.xml").read
        TravisPayloadProcessor.new(project,payload).perform
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        payload = TravisExample.new("failure.xml").read
        TravisPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = TravisExample.new("building.xml").read
        TravisPayloadProcessor.new(project,payload).perform
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end
  end

  describe "saving data" do
    let(:example) { TravisExample.new(xml) }
    let(:payload) { example.read }

    describe "when build was successful" do
      let(:xml)  { "success.xml" }
      its(:latest_status) { should be_success }
      it "should return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("Project").attribute('webUrl').value
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.first_css("Project").attribute("lastBuildTime").value)
      end
    end

    describe "when build failed" do
      let(:xml) { "failure.xml" }
      its(:latest_status) { should_not be_success }
      it "should return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("Project").attribute('webUrl').value
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.first_css("Project").attribute("lastBuildTime").value)
      end
    end
  end

  describe "building status" do
    let(:payload) { TravisExample.new(xml).read }
    let(:xml) { "building.xml" }
    it { should be_building }
    it "should set building to false on the project when it is not building" do
      subject.should be_building
      payload = TravisExample.new("sleeping.xml").read
      TravisPayloadProcessor.new(project,payload).perform
      project.reload.should_not be_building
    end
  end

  describe "with invalid xml" do
    let(:payload) { "<foo><bar>baz</bar></foo>" }
    it { should_not be_building }
    its(:latest_status) { should_not be_success }
  end
end
