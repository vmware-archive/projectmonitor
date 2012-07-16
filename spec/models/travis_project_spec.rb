require 'spec_helper'

describe TravisProject do
  let(:project) { TravisProject.new(:name => "my_travis_project", :feed_url => "http://travis-ci.org/pivotal/projectmonitor/cc.xml") }

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
    it "should require a Travis url format" do
      project.should have(0).errors_on(:feed_url)
      project.feed_url = 'http://foo/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
      project.feed_url = 'http://travis-ci.org/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
      project.feed_url = 'http://travis-ci.org/#!/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
    end

    it "should allow both http and https" do
      project.feed_url = "http://travis-ci.org/pivotal/project-monitor/cc.xml"
      project.should have(0).errors_on(:feed_url)
      project.feed_url = 'https://travis-ci.org/pivotal/projectmonitor/cc.xml'
      project.should have(0).errors_on(:feed_url)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      project.build_status_url.should == "http://travis-ci.org/pivotal/projectmonitor/cc.xml"
    end
  end
end
