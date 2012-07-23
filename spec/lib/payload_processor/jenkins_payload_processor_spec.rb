require 'spec_helper'

describe JenkinsPayloadProcessor do
  let(:project) do
    FactoryGirl.create(
      :jenkins_project,
      jenkins_build_name: "CiMonitor")
  end
  let(:payload) { [JenkinsAtomExample.new(atom).read, nil] }

  subject do
    ProjectPayloadProcessor.new(project, payload).perform
    project.reload
  end

  describe "project status" do
    context "when not currently building" do
      %w(success back_to_normal stable).each do |result|
        context "when build result was #{result}" do
          let(:atom) { "#{result}.atom"}
          it { should be_green }
        end
      end

      context "when build had failed" do
        let(:atom) { "failure.atom"}
        it { should be_red }
      end
    end
    context "when building" do
      it "remains green when existing status is green" do
        payload = [JenkinsAtomExample.new("success.atom").read, nil]
        JenkinsPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = [nil, BuildingStatusExample.new("jenkins_cimonitor_building.atom").read]
        JenkinsPayloadProcessor.new(project,payload).perform
        project.reload.should be_green
        project.statuses.should == statuses
      end

      it "remains red when existing status is red" do
        payload = [JenkinsAtomExample.new("failure.atom").read, nil]
        JenkinsPayloadProcessor.new(project,payload).perform
        statuses = project.statuses
        payload = [nil, BuildingStatusExample.new("jenkins_cimonitor_building.atom").read]
        JenkinsPayloadProcessor.new(project,payload).perform
        project.reload.should be_red
        project.statuses.should == statuses
      end
    end

  end

  describe "building status" do
    let(:payload) { [nil, BuildingStatusExample.new(atom).read] }
    context "when building" do
      let(:atom) { "jenkins_cimonitor_building.atom" }
      it { should be_building }
    end
    context "when not building" do
      let(:atom) { "jenkins_cimonitor_not_building.atom" }
      it { should_not be_building }
    end
  end

  describe "saving data" do
    let(:example) { JenkinsAtomExample.new(atom) }
    let(:payload) { [example.read, nil] }
    describe "when build was successful" do
      let(:atom) { "success.atom" }
      its(:latest_status) { should be_success }
      it "return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("entry:first link").attribute('href').value
      end
      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.first_css("entry:first published").content)
      end
    end
    describe "when build failed" do
      let(:atom) { "failure.atom" }
      its(:latest_status) { should_not be_success }
      it "return the link to the checkin" do
        subject.latest_status.url.should == example.first_css("entry:first link").attribute('href').value
      end
      it "should return the published date of the checkin" do
        subject.latest_status.published_at.should == Time.parse(example.first_css("entry:first published").content)
      end
    end
  end

  describe "with invalid xml" do
    let(:payload) { ["<foo><bar>baz</bar></foo>", nil] }
    it { should_not be_building }
    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
