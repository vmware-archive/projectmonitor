require File.dirname(__FILE__) + '/../spec_helper'
require 'nokogiri'

shared_examples_for "teamcity status for a valid build history xml response" do
  it "should return the link to the checkin" do
    link = @response_doc.css("entry:first link").first.attribute('href').value
    @status_parser.url.should == link
  end

  it "should return the published date of the checkin" do
    date_elements =  @response_doc.css("entry:first published").first
    @status_parser.published_at.should == Time.parse(date_elements.content)
  end
end

describe TeamCityStatusParser do

  TEAMCITY_HISTORY_SUCCESS_XML = File.read('test/fixtures/teamcity_atom_examples/success.atom')
  TEAMCITY_HISTORY_NEVER_GREEN_XML = File.read('test/fixtures/teamcity_atom_examples/never_green.atom')
  TEAMCITY_HISTORY_FAILURE_XML = File.read('test/fixtures/teamcity_atom_examples/failure.atom')
  TEAMCITY_HISTORY_INVALID_XML = "<foo><bar>baz</bar></foo>"

  describe "with reported success" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(TEAMCITY_HISTORY_SUCCESS_XML)
      @status_parser = TeamCityStatusParser.status(TEAMCITY_HISTORY_SUCCESS_XML)
    end

    it_should_behave_like "teamcity status for a valid build history xml response"

    it "should report success" do
      @status_parser.should be_success
    end
  end

  describe "with reported failure" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(TEAMCITY_HISTORY_FAILURE_XML)
      @status_parser = TeamCityStatusParser.status(TEAMCITY_HISTORY_FAILURE_XML)
    end

    it_should_behave_like "teamcity status for a valid build history xml response"

    it "should report failure" do
      @status_parser.should_not be_success
    end
  end

  describe "with invalid xml" do
    before(:all) do
      @parser = Nokogiri::XML.parse(@response_xml = TEAMCITY_HISTORY_INVALID_XML)
      @response_doc = @parser.parse
      @status_parser = TeamCityStatusParser.status(TEAMCITY_HISTORY_INVALID_XML)
    end
  end

#  describe "building" do
#    TEAMCITY_BUILDING_XML = File.read('test/fixtures/building_status_examples/teamcity_pulse_building.atom')
#    TEAMCITY_NOT_BUILDING_XML = File.read('test/fixtures/building_status_examples/teamcity_pulse_not_building.atom')
#    TEAMCITY_BUILDING_INVALID_XML = "<foo><bar>baz</bar></foo>"
#
#    context "with a valid response that the project is building" do
#      before(:each) do
#        @status_parser = TeamCityStatusParser.building(TEAMCITY_BUILDING_XML, stub("a project", :project_name => 'Pulse'))
#      end
#
#      it "should set the building flag on the project to true" do
#        @status_parser.should be_building
#      end
#    end
#
#    context "with a valid response that the project is not building" do
#      before(:each) do
#        @status_parser = TeamCityStatusParser.building(TEAMCITY_NOT_BUILDING_XML, stub("a project", :project_name => 'Pulse'))
#      end
#
#      it "should set the building flag on the project to false" do
#        @status_parser.should_not be_building
#      end
#    end
#
#    context "with an invalid response" do
#      before(:each) do
#        @status_parser = TeamCityStatusParser.building(TEAMCITY_BUILDING_INVALID_XML, stub("a project", :project_name => 'Socialitis'))
#      end
#
#      it "should set the building flag on the project to false" do
#        @status_parser.should_not be_building
#      end
#    end
#  end
end

