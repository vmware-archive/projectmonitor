require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

shared_examples_for "teamcity status for a valid build history xml response" do
  it "should return the link to the checkin" do
    link = @response_doc.css("Build").first.attribute('webUrl').value
    @status_parser.url.should == link
  end

  it "should return the published date of the checkin" do
    date_elements = @response_doc.css("Build").first.attribute('lastBuildTime')
    @status_parser.published_at.should == Time.parse(date_elements.content)
  end
end

describe TeamCityStatusParser do

  describe "with reported success" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(TeamcityCradiatorXmlExample.new("success.xml"))
      @status_parser = TeamCityStatusParser.status(TeamcityCradiatorXmlExample.new("success.xml"))
    end

    it_should_behave_like "teamcity status for a valid build history xml response"

    it "should report success" do
      @status_parser.should be_success
    end
  end

  describe "with reported failure" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(TeamcityCradiatorXmlExample.new("failure.xml"))
      @status_parser = TeamCityStatusParser.status(TeamcityCradiatorXmlExample.new("failure.xml"))
    end

    it_should_behave_like "teamcity status for a valid build history xml response"

    it "should report failure" do
      @status_parser.should_not be_success
    end
  end

  describe "with invalid xml" do
    before(:all) do
      @parser = Nokogiri::XML.parse(@response_xml = "<foo><bar>baz</bar></foo>")
      @response_doc = @parser.parse
      @status_parser = TeamCityStatusParser.status("<foo><bar>baz</bar></foo>")
    end
  end

  describe "building" do
    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = TeamCityStatusParser.building(BuildingStatusExample.new("team_city_building.xml"), stub("a project", :project_name => 'Pulse'))
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = TeamCityStatusParser.building(BuildingStatusExample.new("team_city_not_building.xml"), stub("a project", :project_name => 'Pulse'))
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end

    context "with an invalid response" do
      before(:each) do
        @status_parser = TeamCityStatusParser.building("<foo><bar>baz</bar></foo>", stub("a project", :project_name => 'Pulse'))
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end
  end
end

