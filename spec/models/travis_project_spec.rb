require 'spec_helper'

describe TravisProject do
  let(:project) { TravisProject.new(:name => "my_travis_project", :feed_url => "http://travis-ci.org/pivotal/projectmonitor/builds.json") }

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
      project.should have(0).errors_on(:feed_url)
      project.feed_url = 'https://travis-ci.org/pivotal/projectmonitor/builds.json'
      project.should have(0).errors_on(:feed_url)
    end
  end
end
