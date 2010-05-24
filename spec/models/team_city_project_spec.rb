require File.dirname(__FILE__) + '/../spec_helper'

describe TeamCityProject do
  before(:each) do
    @project = TeamCityProject.new(:name => "my_teamcity_project", :feed_url => "http://foo.bar.com:3434/feed.html?buildTypeId=bt2&itemsType=builds")
  end
  
  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should return the Atom url, since TeamCity does not have the project name in the feed_url" do
      @project.project_name.should == @project.feed_url
    end

  end

  describe 'validations' do
    it "should require a TeamCity url format" do
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/wrong/example_project/rssAll'
      @project.should have(1).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/job/example_project/wrong'
      @project.should have(1).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/feed.html'
      @project.should have(1).errors_on(:feed_url)
    end
  end

  describe "status parsers" do
    it "should handle bad xml" do
      @project.status_parser('asdfa').should_not be_nil
      @project.building_parser('asdfas').should_not be_nil
    end
    
    it "should be for TeamCity" do
      @project.status_parser('xml').should be_a(TeamCityStatusParser)
      @project.building_parser('xml').should be_a(TeamCityStatusParser)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/cc.xml"
    end
  end
end
