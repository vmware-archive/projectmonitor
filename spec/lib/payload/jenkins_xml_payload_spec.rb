require 'spec_helper'
require Rails.root.join('spec', 'shared', 'xml_payload_examples')

describe JenkinsXmlPayload do
  let(:fixture_ext)         { "atom" }
  let(:fixture_dir)         { 'jenkins_atom_examples' }
  let(:fixture_content)     { load_fixture(fixture_dir, fixture_file) }
  let(:build_fixture_file)  { "jenkins_projectmonitor_building.atom" }
  let(:build_content)       { load_fixture(fixture_dir, build_fixture_file) }

  let(:project)           { create(:jenkins_project, ci_build_identifier: "ProjectMonitor") }
  let(:payload)           { JenkinsXmlPayload.new(project.ci_build_identifier) }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }

  subject do
    payload_processor.process_payload(project: project, payload: payload)
    project
  end

  it_behaves_like "a XML payload"

  describe "project status" do
    context "when not currently building" do
      before(:each) { payload.status_content = fixture_content }

      # success.atom & failure.atom covered in shared examples
      context "when build result was back_to_normal" do
        let(:fixture_file) { "back_to_normal.atom" }
        it { is_expected.to be_success }
      end

      context "when build result was stable" do
        let(:fixture_file) { "stable.atom" }
        it { is_expected.to be_success }
      end
    end
  end

  describe "building status" do
    let(:build_content) { load_fixture(fixture_dir, fixture_file) }
    before { payload.build_status_content = build_content }

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
    let(:parsed_content) { Nokogiri::XML(fixture_content) }
    before { payload.status_content = fixture_content }

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

end
