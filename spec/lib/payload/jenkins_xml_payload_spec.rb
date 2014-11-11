require 'spec_helper'

describe JenkinsXmlPayload do
  let(:fixture_dir) { 'jenkins_atom_examples' }
  let(:project) { create(:jenkins_project, ci_build_identifier: "ProjectMonitor") }
  let(:status_content) { load_fixture(fixture_dir, fixture_file) }
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
          let(:fixture_file) { "#{result}.atom" }
          it { is_expected.to be_success }
        end
      end

      context "when build had failed" do
        let(:fixture_file) { "failure.atom" }
        it { is_expected.to be_failure }
      end
    end

    context "when building" do
      it "remains green when existing status is green" do
        jenkins_payload.status_content = load_fixture(fixture_dir, "success.atom")
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        statuses = project.statuses
        jenkins_payload.build_status_content = load_fixture(fixture_dir, 'jenkins_projectmonitor_building.atom')
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        expect(project).to be_success
        expect(project.statuses).to eq(statuses)
      end

      it "remains red when existing status is red" do
        jenkins_payload.status_content = load_fixture(fixture_dir, "failure.atom")
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        statuses = project.statuses
        jenkins_payload.build_status_content = load_fixture(fixture_dir, 'jenkins_projectmonitor_building.atom')
        payload_processor.process_payload(project: project, payload: jenkins_payload)
        expect(project).to be_failure
        expect(project.statuses).to eq(statuses)
      end
    end
  end

  describe "building status" do
    let(:build_content) { load_fixture(fixture_dir, fixture_file) }
    before { jenkins_payload.build_status_content = build_content }

    context "when building" do
      let(:fixture_file) { "jenkins_projectmonitor_building.atom" }
      it { is_expected.to be_building }
    end

    context "when not building" do
      let(:fixture_file) { "jenkins_projectmonitor_not_building.atom" }
      it { is_expected.not_to be_building }
    end
  end

  describe "saving data" do
    let(:parsed_content) { Nokogiri::XML(status_content) }
    before { jenkins_payload.status_content = status_content }

    describe "when build was successful" do
      let(:fixture_file) { "success.atom" }

      describe '#latest_status' do
        subject { super().latest_status }
        it { is_expected.to be_success }
      end

      it "return the link to the checkin" do
        expect(subject.latest_status.url).to eq(parsed_content.at_css("entry:first link").attribute('href').value)
      end

      it "should return the published date of the checkin" do
        expect(subject.latest_status.published_at).to eq(Time.parse(parsed_content.at_css("entry:first published").content))
      end
    end

    describe "when build failed" do
      let(:fixture_file) { "failure.atom" }

      describe '#latest_status' do
        subject { super().latest_status }
        it { is_expected.not_to be_success }
      end

      it "return the link to the checkin" do
        expect(subject.latest_status.url).to eq(parsed_content.at_css("entry:first link").attribute('href').value)
      end

      it "should return the published date of the checkin" do
        expect(subject.latest_status.published_at).to eq(Time.parse(parsed_content.at_css("entry:first published").content))
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
