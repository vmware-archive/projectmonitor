require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe TeamCityProject do
  before(:each) do
    @project = TeamCityProject.new(:name => "my_teamcity_project", :feed_url => "http://foo.bar.com:3434/guestAuth/cradiator.html?buildTypeId=bt9")
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

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/guestAuth/cradiator.html?buildTypeId=bt9"
    end
  end

  describe "#status_parser" do

    describe "with reported success" do
      before(:each) do
        @status_parser = @project.status_parser(TeamcityCradiatorXmlExample.new("success.xml").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == TeamcityCradiatorXmlExample.new("success.xml").first_css("Build").attribute("webUrl").value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(TeamcityCradiatorXmlExample.new("success.xml").first_css("Build").attribute("lastBuildTime").content)
      end

      it "should report success" do
        @status_parser.should be_success
      end
    end

    describe "with reported failure" do
      before(:each) do
        @status_parser = @project.status_parser(TeamcityCradiatorXmlExample.new("failure.xml").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == TeamcityCradiatorXmlExample.new("failure.xml").first_css("Build").attribute("webUrl").value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(TeamcityCradiatorXmlExample.new("failure.xml").first_css("Build").attribute("lastBuildTime").content)
      end

      it "should report failure" do
        @status_parser.should_not be_success
      end
    end

    describe "with invalid xml" do
      before(:each) do
        @parser = Nokogiri::XML.parse(@response_xml = "<foo><bar>baz</bar></foo>")
        @response_doc = @parser.parse
        @status_parser = @project.status_parser("<foo><bar>baz</bar></foo>")
      end
    end
  end

  describe "#building_parser" do
    before(:each) do
      @project = TeamCityProject.new(:name => "my_teamcity_project", :feed_url => "Pulse")
    end

    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = @project.building_parser(BuildingStatusExample.new("team_city_building.xml").read)
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = @project.building_parser(BuildingStatusExample.new("team_city_not_building.xml").read)
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end

    context "with an invalid response" do
      before(:each) do
        @status_parser = @project.building_parser("<foo><bar>baz</bar></foo>")
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end
  end

end
