require 'spec_helper'

describe JenkinsXmlPayload do
  let(:project) { create(:jenkins_project, ci_build_identifier: "ProjectMonitor") }
  let(:status_content) { JenkinsAtomExample.new(atom).read }
  let(:jenkins_payload) { JenkinsXmlPayload.new(project.ci_build_identifier) }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }

  subject do
    payload_processor.process_payload(project: project, payload: jenkins_payload)
    project
  end

  describe "project status" do
    context "when not currently building" do
      before { jenkins_payload.status_content = status_content }

      %w(success back_to_normal stable).each do |result|
        context "when build result was #{result}" do
          let(:atom) { "#{result}.atom" }
          it { is_expected.to be_success }
        end
      end

      context "when build had failed" do
        let(:atom) { "failure.atom" }
        it { is_expected.to be_failure }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        content = JenkinsAtomExample.new("success.atom").read
        jenkins_payload.status_content = content
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        statuses = project.statuses
        content = BuildingStatusExample.new("jenkins_projectmonitor_building.atom").read
        jenkins_payload.build_status_content = content
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        expect(project).to be_success
        expect(project.statuses).to eq(statuses)
      end

      it "remains red when existing status is red" do
        content = JenkinsAtomExample.new("failure.atom").read
        jenkins_payload.status_content = content
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        statuses = project.statuses
        content = BuildingStatusExample.new("jenkins_projectmonitor_building.atom").read
        jenkins_payload.build_status_content = content
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        expect(project).to be_failure
        expect(project.statuses).to eq(statuses)
      end
    end

  end

  describe "building status" do
    let(:build_content) { BuildingStatusExample.new(atom).read }
    before { jenkins_payload.build_status_content = build_content }

    context "when building" do
      let(:atom) { "jenkins_projectmonitor_building.atom" }
      it { is_expected.to be_building }
    end

    context "when not building" do
      let(:atom) { "jenkins_projectmonitor_not_building.atom" }
      it { is_expected.not_to be_building }
    end
  end

  describe "saving data" do
    let(:example) { JenkinsAtomExample.new(atom) }
    let(:status_content) { example.read }
    before { jenkins_payload.status_content = status_content }

    describe "when build was successful" do
      let(:atom) { "success.atom" }

      describe '#latest_status' do
        subject { super().latest_status }
        it { is_expected.to be_success }
      end

      it "return the link to the checkin" do
        expect(subject.latest_status.url).to eq(example.first_css("entry:first link").attribute('href').value)
      end

      it "should return the published date of the checkin" do
        expect(subject.latest_status.published_at).to eq(Time.parse(example.first_css("entry:first published").content))
      end
    end

    describe "when build failed" do
      let(:atom) { "failure.atom" }

      describe '#latest_status' do
        subject { super().latest_status }
        it { is_expected.not_to be_success }
      end

      it "return the link to the checkin" do
        expect(subject.latest_status.url).to eq(example.first_css("entry:first link").attribute('href').value)
      end

      it "should return the published date of the checkin" do
        expect(subject.latest_status.published_at).to eq(Time.parse(example.first_css("entry:first published").content))
      end
    end
  end

  describe "#build_status_content" do
    let(:wrong_status_content) { "some non xml content" }
    context "invalid xml" do
      it 'should log error message' do
        expect(jenkins_payload).to receive("log_error")
        jenkins_payload.build_status_content = wrong_status_content
      end
    end
  end
  describe "with invalid xml" do
    let(:status_content) { "<foo><bar>baz</bar></foo>" }

    it { is_expected.not_to be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end

    context "bad XML data" do
      let(:wrong_status_content) { "some non xml content" }
      it "should log errors" do
        expect(jenkins_payload).to receive("log_error")
        jenkins_payload.status_content = wrong_status_content
      end
    end
  end
end
