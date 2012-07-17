require 'spec_helper'

describe JenkinsProject do
  before do
    @project = JenkinsProject.new(:name => "my_jenkins_project", :feed_url => "http://foo.bar.com:3434/job/example_project/rssAll")
  end

  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should extract the project name from the Atom url" do
      @project.project_name.should == "example_project"
    end

    it "should extract the project name from the Atom url regardless of capitalization" do
      @project.feed_url = @project.feed_url.upcase
      @project.project_name.should == "EXAMPLE_PROJECT"
    end
  end

  describe 'validations' do
    it { should validate_presence_of :url }
    it { should validate_presence_of :build_name }
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/cc.xml"
    end
  end

  describe '#url' do
    subject { FactoryGirl.build(:jenkins_project) }

    it 'should read the url from the feed URL' do
      subject.feed_url = "http://foo.bar.com:3434/job/example_project/rssAll"
      subject.url.should == "http://foo.bar.com:3434"

      subject.feed_url = "https://foo2.bar2.org:3538/job/example_project/rssAll"
      subject.url.should == "https://foo2.bar2.org:3538"
    end
  end

  describe '#build_name' do
    subject { FactoryGirl.build(:jenkins_project) }

    it 'should read the build_name from the feed URL' do
      subject.feed_url = "http://foo.bar.com:3434/job/example_project/rssAll"
      subject.build_name.should == "example_project"

      subject.feed_url = "https://foo2.bar2.org:3538/job/example_project_2/rssAll"
      subject.build_name.should == "example_project_2"
    end
  end
end
