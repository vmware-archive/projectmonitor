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
    it "should require a Jenkins url format" do
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/wrong/example_project/rssAll'
      @project.should have(1).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/job/example_project/wrong'
      @project.should have(1).errors_on(:feed_url)
    end

    it "should allow both http and https" do
      @project.feed_url = "http://foo.bar.com:3434/job/example_project/rssAll"
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'https://foo.bar.com:3434/job/example_project/rssAll'
      @project.should have(0).errors_on(:feed_url)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/cc.xml"
    end
  end
end
