require 'spec_helper'

describe TravisPayload do
  let(:project) { FactoryGirl.create(:travis_project) }
  let(:status_content) { TravisExample.new(json).read }
  let(:travis_payload) { TravisPayload.new(project).tap{|p| p.status_content = status_content} }

  subject do
    ProjectPayloadProcessor.new(project, travis_payload).process
    project.reload
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
      let(:travis_payload) { TravisPayload.new(project) }

      it "remains green when existing status is green" do
        content = TravisExample.new("success.json").read
        travis_payload.status_content = content
        ProjectPayloadProcessor.new(project,travis_payload).process
        statuses = project.recent_statuses
        content = TravisExample.new("building.json").read
        travis_payload.status_content = content
        ProjectPayloadProcessor.new(project,travis_payload).process
        project.reload.should be_green
        project.should be_online
        project.recent_statuses.should == statuses
      end

      it "remains red when existing status is red" do
        content = TravisExample.new("failure.json").read
        travis_payload.status_content = content
        ProjectPayloadProcessor.new(project,travis_payload).process
        statuses = project.recent_statuses
        content = TravisExample.new("building.json").read
        travis_payload.status_content = content
        ProjectPayloadProcessor.new(project,travis_payload).process
        project.reload.should be_red
        project.should be_online
        project.recent_statuses.should == statuses
      end
    end
  end

  describe "saving data" do
    let(:example) { TravisExample.new(json) }
    let(:travis_payload) { TravisPayload.new(project).tap{|p| p.status_content = example.read } }

    describe "when build was successful" do
      let(:json) { "success.json" }

      its(:latest_status) { should be_success }

      it "should return the link to the checkin" do
        subject.latest_status.url.should == project.feed_url.gsub(".json", "/#{example.as_json.first["id"]}")
      end

      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.as_json.first["finished_at"])
      end

      it "should return the build id" do
        subject.latest_status.build_id.should == example.as_json.first["id"]
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

      it "should return the build id" do
        subject.latest_status.build_id.should == example.as_json.first["id"]
      end
    end
  end

  describe "building status" do
    let(:status_content) { TravisExample.new(json).read }
    let(:travis_payload) { TravisPayload.new(project).tap{|p| p.status_content = status_content } }
    let(:json) { "building.json" }

    it { should be_building }
    it { should be_online }

    it "should set building to false on the project when it is not building" do
      subject.should be_building
      travis_payload.status_content = TravisExample.new("failure.json").read
      ProjectPayloadProcessor.new(project,travis_payload).process
      project.reload.should_not be_building
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
