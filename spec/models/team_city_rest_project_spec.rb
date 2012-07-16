require 'spec_helper'

describe TeamCityRestProject do
  let(:project) { TeamCityRestProject.new(:name => "my_teamcity_project", :feed_url => rest_url) }
  let(:rest_url) { "http://foo.bar.com:3434/app/rest/builds?locator=running:all,buildType:(id:bt3)" }

  context "TeamCity REST API feed with both the personal and user option" do
    it "should be valid" do
      project.feed_url = "#{rest_url},user:some_user123,personal:true"
      project.should be_valid
    end
  end

  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      project.feed_url = nil
      project.project_name.should be_nil
    end

    it "should return the feed url, since TeamCity does not have the project name in the feed_url" do
      project.project_name.should == project.feed_url
    end
  end

  describe "#build_status_url" do
    it "should use rest api" do
      project.build_status_url.should == rest_url
    end
  end
end
