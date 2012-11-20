require 'spec_helper'

describe JenkinsProject do
  subject { FactoryGirl.build(:jenkins_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:jenkins_project) }
    it { should be_valid }
  end

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { Project.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:jenkins_base_url) }
      it { should_not validate_presence_of(:jenkins_build_name) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of :jenkins_base_url }
      it { should validate_presence_of :jenkins_build_name }

      it do
        should allow_value("http://example.com",
                           "https://example.com",
                           "HTTP://example.com").for(:jenkins_base_url)
      end

      it do
        should_not allow_value("ttp://example.com",
                               "sql injection\nhttps://example.com").for(:jenkins_base_url)

      end
    end
  end

  its(:feed_url) { should == "http://www.example.com/job/project/rssAll" }
  its(:project_name) { should == 'project' }

  describe "#build_status_url" do
    subject { project.build_status_url }

    let(:project) { JenkinsProject.new(jenkins_base_url: base_url) }

    context "when base_url is nil" do
      let(:base_url) { nil }

      it { should be_nil }
    end

    context "when the base_url is not nil" do
      context "when the base_url has a scheme specified" do
        let(:base_url) { "http://ci-server:8080" }

        it { should == "http://ci-server:8080/cc.xml" }
      end

      context "when the base_url does not hav a scheme specified" do
        let(:base_url) { "ci-server:8080" }

        it { should == "ci-server:8080/cc.xml" }
      end
    end
  end

  describe '#current_build_url' do
    subject { project.current_build_url }
    context "webhooks are enabled" do
      let(:project) { FactoryGirl.build(:jenkins_project, webhooks_enabled: true, parsed_url: 'foo.gov') }
      it { should == 'foo.gov'}
    end
    context "webhooks are disabled" do
      let(:project) { FactoryGirl.build(:jenkins_project) }

      it { should == 'http://www.example.com' }
    end
  end
end
