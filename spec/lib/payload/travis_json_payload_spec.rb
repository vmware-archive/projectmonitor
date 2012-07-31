require 'spec_helper'

describe TravisJsonPayload do
  let(:project) { FactoryGirl.create(:travis_project) }
  let(:status_content) { TravisExample.new(json).read }
  let(:travis_payload) { TravisJsonPayload.new.tap{|p| p.status_content = status_content} }

  subject do
    PayloadProcessor.new(project, travis_payload).process
    project
  end

  describe "project status" do
    context "when not currently building" do

      context "when latest build is successful" do
        let(:json) { "success.json" }
        it { should be_green }
        it { should be_online }

        it "doesn't add a duplicate of the existing status" do
          latest_status = subject.latest_status
          statuses = project.recent_statuses
          subject.latest_status.should == latest_status
          project.recent_statuses.should == statuses
        end
      end

      context "when latest build has failed" do
        let(:json) { "failure.json" }
        it { should be_red }
        it { should be_online }
      end
    end

    context "when building" do
      let(:travis_payload) { TravisJsonPayload.new }

      it "remains green when existing status is green" do
        content = TravisExample.new("success.json").read
        travis_payload.status_content = content
        PayloadProcessor.new(project,travis_payload).process
        statuses = project.recent_statuses
        content = TravisExample.new("building.json").read
        travis_payload.status_content = content
        PayloadProcessor.new(project,travis_payload).process
        project.should be_green
        project.should be_online
        project.recent_statuses.should == statuses
      end

      it "remains red when existing status is red" do
        content = TravisExample.new("failure.json").read
        travis_payload.status_content = content
        PayloadProcessor.new(project,travis_payload).process
        statuses = project.recent_statuses
        content = TravisExample.new("building.json").read
        travis_payload.status_content = content
        PayloadProcessor.new(project,travis_payload).process
        project.should be_red
        project.should be_online
        project.recent_statuses.should == statuses
      end
    end
  end

  describe "saving data" do
    let(:example) { TravisExample.new("success.json") }
    let(:travis_payload) { TravisJsonPayload.new.tap{|p| p.status_content = example.read } }

    # it "should return the link to the checkin" do
      # subject.latest_status.url.should == project.feed_url.gsub(".json", "/#{example.as_json.first["id"]}")
    # end

    it "should return the published date of the checkin" do
      subject.latest_status.published_at.should == Time.parse(example.as_json.first["finished_at"])
    end

    it "should return the build id" do
      subject.latest_status.build_id.should == example.as_json.first["id"]
    end

    describe "when build was successful" do
      its(:latest_status) { should be_success }
    end

    describe "when build failed" do
      let(:example) { TravisExample.new("failure.json") }
      its(:latest_status) { should_not be_success }
    end
  end

  describe "building status" do
    let(:status_content) { TravisExample.new(json).read }
    let(:travis_payload) { TravisJsonPayload.new.tap{|p| p.status_content = status_content } }
    let(:json) { "building.json" }

    it { should be_building }
    it { should be_online }

    it "should set building to false on the project when it is not building" do
      subject.should be_building
      travis_payload.status_content = TravisExample.new("failure.json").read
      PayloadProcessor.new(project,travis_payload).process
      project.should_not be_building
    end
  end

  describe "with invalid json" do
    let(:status_content) { "{jdskfld;fd;shg}" }

    it { should_not be_building }
    it { should_not be_online }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
