require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))
require 'nokogiri'

shared_examples_for "hudson status for a valid build history xml response" do
  it "should return the link to the checkin" do
    link = @response_doc.css("entry:first link").first.attribute('href').value
    @status_parser.url.should == link
  end

  it "should return the published date of the checkin" do
    date_elements =  @response_doc.css("entry:first published").first
    @status_parser.published_at.should == Time.parse(date_elements.content)
  end
end

describe HudsonStatusParser do

  describe "with reported success" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(HudsonAtomExample.new("success.atom"))
      @status_parser = HudsonStatusParser.status(HudsonAtomExample.new("success.atom"))
    end

    it_should_behave_like "hudson status for a valid build history xml response"

    it "should report success" do
      @status_parser.should be_success
    end
  end

  describe "with reported failure" do
    before(:all) do
      @response_doc = Nokogiri::XML.parse(HudsonAtomExample.new("failure.atom"))
      @status_parser = HudsonStatusParser.status(HudsonAtomExample.new("failure.atom"))
    end

    it_should_behave_like "hudson status for a valid build history xml response"

    it "should report failure" do
      @status_parser.should_not be_success
    end
  end

  describe "with invalid xml" do
    before(:all) do
      @parser = Nokogiri::XML.parse(@response_xml = "<foo><bar>baz</bar></foo>")
      @response_doc = @parser.parse
      @status_parser = HudsonStatusParser.status("<foo><bar>baz</bar></foo>")
    end
  end

  describe "building" do
    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = HudsonStatusParser.building(BuildingStatusExample.new("hudson_cimonitor_building.atom"), stub("a project", :project_name => 'CiMonitor'))
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = HudsonStatusParser.building(BuildingStatusExample.new("hudson_cimonitor_not_building.atom"), stub("a project", :project_name => 'CiMonitor'))
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end

    context "with an invalid response" do
      before(:each) do
        @status_parser = HudsonStatusParser.building("<foo><bar>baz</bar></foo>", stub("a project", :project_name => 'Socialitis'))
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end
  end
end

