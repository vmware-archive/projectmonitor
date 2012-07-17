require 'spec_helper'

describe TravisPayloadProcessor do
  let(:project) { TravisProject.create(name: "foo", feed_url: "http://travis-ci.org/account/project/builds.json") }
  let(:payload) { TravisExample.new(json).read }

  subject do
    ProjectPayloadProcessor.new(project, payload).perform
    project.reload
  end

  describe "project status" do
    context "when not currently building" do

      context "when latest build is successful" do
        let(:json) { "success.json" }
        it { should be_green }

        it "doesn't add a duplicate of the existing status" do
          latest_status = subject.latest_status
          statuses = project.statuses
          subject.latest_status.should == latest_status
          project.statuses.should == statuses
        end
      end

      context "when latest build has failed" do
        let(:json) { "failure.json" }
        it { should be_red }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        payload = TravisExample.new("success.json").read
        TravisPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = TravisExample.new("building.json").read
        TravisPayloadProcessor.new(project,payload).perform
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        payload = TravisExample.new("failure.json").read
        TravisPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = TravisExample.new("building.json").read
        TravisPayloadProcessor.new(project,payload).perform
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end
  end

  describe "saving data" do
    let(:example) { TravisExample.new(json) }
    let(:payload) { example.read }

    describe "when build was successful" do
      let(:json)  { "success.json" }
      its(:latest_status) { should be_success }
      it "should return the link to the checkin" do
        subject.latest_status.url.should == project.feed_url.gsub(".json", "/#{example.as_json.first["id"]}")
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.as_json.first["finished_at"])
      end
    end

    describe "when build failed" do
      let(:json) { "failure.json" }
      its(:latest_status) { should_not be_success }
      it "should return the link to the checkin" do
        subject.latest_status.url.should == project.feed_url.gsub(".json", "/#{example.as_json.first["id"]}")
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.as_json.first["finished_at"])
      end
    end
  end

  describe "building status" do
    let(:payload) { TravisExample.new(json).read }
    let(:json) { "building.json" }
    it { should be_building }
    it "should set building to false on the project when it is not building" do
      subject.should be_building
      payload = TravisExample.new("failure.json").read
      TravisPayloadProcessor.new(project,payload).perform
      project.reload.should_not be_building
    end
  end

  describe "with invalid json" do
    let(:payload) { "{jdskfld;fd;shg}" }
    it { should_not be_building }
    its(:latest_status) { should_not be_success }
  end
end
