require 'spec_helper'

describe TravisProject do
  let(:project) { TravisProject.new(:name => "my_travis_project", :feed_url => "http://travis-ci.org/pivotal/projectmonitor/builds.json") }

  it { should validate_presence_of(:account) }
  it { should validate_presence_of(:project) }

  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      project.feed_url = nil
      project.project_name.should be_nil
    end

    it "should extract the project name from the feed url" do
      project.project_name.should == "projectmonitor"
    end
  end

  describe 'validations' do
    it "should allow both http and https" do
      project.feed_url = "http://travis-ci.org/pivotal/project-monitor/builds.json"
      project.should be_valid
      project.feed_url = 'https://travis-ci.org/pivotal/projectmonitor/builds.json'
      project.should be_valid
    end
  end

  describe '#save' do
    context 'on create' do
      subject { FactoryGirl.build(:travis_project) }

      it 'should build the feed URL' do
        subject.account = "pivotal"
        subject.project = "projectmonitor"
        subject.save!
        subject.feed_url.should == "http://travis-ci.org/pivotal/projectmonitor/builds.json"
      end
    end
  end

  describe '#account' do
    subject { FactoryGirl.build(:travis_project) }

    it 'should read the account from the feed URL' do
      subject.feed_url = "http://travis-ci.org/pivotal/projectmonitor/builds.json"
      subject.account.should == "pivotal"

      subject.feed_url = "http://travis-ci.org/pivotal2/projectmonitor/builds.json"
      subject.account.should == "pivotal2"
    end
  end

  describe '#project' do
    subject { FactoryGirl.build(:travis_project) }

    it 'should read the project from the feed URL' do
      subject.feed_url = "http://travis-ci.org/pivotal/projectmonitor/builds.json"
      subject.project.should == "projectmonitor"

      subject.feed_url = "http://travis-ci.org/pivotal/projectmonitor2/builds.json"
      subject.project.should == "projectmonitor2"
    end
  end
end
