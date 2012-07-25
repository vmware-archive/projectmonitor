require 'spec_helper'

describe JenkinsProject do
  subject { FactoryGirl.build(:jenkins_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:jenkins_project) }
    it { should be_valid }
  end

  describe 'validations' do
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

  its(:feed_url) { should == "http://www.example.com/job/project/rssAll" }
  its(:project_name) { should == 'project' }

  describe "#build_status_url" do
    let(:project) { FactoryGirl.build(:jenkins_project) }
    subject { project.build_status_url }

    it { should match %r{\Ahttp://www.example.com} }
    it { should include 'cc.xml' }
  end

  describe '#status_url' do
    let(:project) { FactoryGirl.build(:jenkins_project) }
    subject { project.status_url }

    it { should == 'http://www.example.com' }
  end

end
