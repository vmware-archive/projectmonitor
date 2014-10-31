require 'spec_helper'

describe JenkinsProject, :type => :model do
  describe 'validations' do
    subject { FactoryGirl.build(:jenkins_project, webhooks_enabled: webhooks_enabled)}

    context "when webhooks are enabled" do
      let(:webhooks_enabled) { true }

      it { is_expected.not_to validate_presence_of(:jenkins_base_url) }
      it { is_expected.not_to validate_presence_of(:jenkins_build_name) }
    end

    context "when webhooks are not enabled" do
      let(:webhooks_enabled) { false }

      it { is_expected.to validate_presence_of :jenkins_base_url }
      it { is_expected.to validate_presence_of :jenkins_build_name }
    end
  end

  describe "#feed_url" do
    subject { project.feed_url }

    let(:project) { JenkinsProject.new(jenkins_base_url: "ci-server", jenkins_build_name: "specs") }

    it { is_expected.to eq("ci-server/job/specs/rssAll") }
  end

  describe "#project_name" do
    subject { project.project_name }

    let(:project) { JenkinsProject.new(jenkins_build_name: "specs") }

    it { is_expected.to eq("specs") }
  end

  describe "#build_status_url" do
    subject { project.build_status_url }

    let(:project) { JenkinsProject.new(jenkins_base_url: base_url) }

    context "when base_url is nil" do
      let(:base_url) { nil }

      it { is_expected.to be_nil }
    end

    context "when the base_url is not nil" do
      context "when the base_url has a scheme specified" do
        let(:base_url) { "http://ci-server:8080" }

        it { is_expected.to eq("http://ci-server:8080/cc.xml") }
      end

      context "when the base_url does not hav a scheme specified" do
        let(:base_url) { "ci-server:8080" }

        it { is_expected.to eq("ci-server:8080/cc.xml") }
      end
    end
  end

  describe "#fetch_payload" do
    subject { project.fetch_payload }

    let(:project) { JenkinsProject.new(jenkins_build_name: "features") }
    let(:xml_payload) { double(:xml_payload) }

    before do
      expect(JenkinsXmlPayload).to receive(:new).with("features").and_return(xml_payload)
    end

    it { is_expected.to eq(xml_payload) }
  end

  describe "#webhook_payload" do
    subject { project.webhook_payload }

    let(:project) { JenkinsProject.new }
    let(:json_payload) { double(:json_payload) }

    before do
      expect(JenkinsJsonPayload).to receive(:new).and_return(json_payload)
    end

    it { is_expected.to eq(json_payload) }
  end
end
