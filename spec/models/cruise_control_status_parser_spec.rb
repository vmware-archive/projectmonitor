require File.dirname(__FILE__) + '/../spec_helper'
require 'xml/libxml'

shared_examples_for "cc status for a valid build history xml response" do
  it "should return the link to the checkin" do
    link_elements = @response_doc.find("/rss/channel/item/link")
    link_elements.size.should == 1
    @status_parser.url.should == link_elements.first.content
  end

  it "should return the published date of the checkin" do
    date_elements = @response_doc.find("/rss/channel/item/pubDate")
    date_elements.size.should == 1
    @status_parser.published_at.should == Time.parse(date_elements.first.content)
  end
end

describe CruiseControlStatusParser do

  CC_HISTORY_SUCCESS_XML = File.read('test/fixtures/cc_rss_examples/success.rss')
  CC_HISTORY_NEVER_GREEN_XML = File.read('test/fixtures/cc_rss_examples/never_green.rss')
  CC_HISTORY_FAILURE_XML = File.read('test/fixtures/cc_rss_examples/failure.rss')
  CC_HISTORY_INVALID_XML = "<foo><bar>baz</bar></foo>"

  describe "with reported success" do
    before(:all) do
      @parser = XML::Parser.string(@response_xml = CC_HISTORY_SUCCESS_XML)
      @response_doc = @parser.parse
      @status_parser = CruiseControlStatusParser.status(CC_HISTORY_SUCCESS_XML)
    end

    it_should_behave_like "cc status for a valid build history xml response"

    it "should report success" do
      @status_parser.should be_success
    end
  end

  describe "with reported failure" do
    before(:all) do
      @parser = XML::Parser.string(@response_xml = CC_HISTORY_FAILURE_XML)
      @response_doc = @parser.parse
      @status_parser = CruiseControlStatusParser.status(CC_HISTORY_FAILURE_XML)
    end

    it_should_behave_like "cc status for a valid build history xml response"

    it "should report failure" do
      @status_parser.should_not be_success
    end
  end

  describe "with invalid xml" do
    before(:all) do
      @parser = XML::Parser.string(@response_xml = CC_HISTORY_INVALID_XML)
      @response_doc = @parser.parse
      @status_parser = CruiseControlStatusParser.status(CC_HISTORY_INVALID_XML)
    end
  end
end

describe "building" do
  CC_BUILDING_XML = File.read('test/fixtures/building_status_examples/socialitis_building.xml')
  CC_NOT_BUILDING_XML = File.read('test/fixtures/building_status_examples/socialitis_not_building.xml')
  CC_BUILDING_INVALID_XML = "<foo><bar>baz</bar></foo>"

  context "with a valid response that the project is building" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building(CC_BUILDING_XML, stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to true" do
      @status_parser.should be_building
    end
  end

  context "with a valid response that the project is not building" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building(CC_NOT_BUILDING_XML, stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to false" do
      @status_parser.should_not be_building
    end
  end

  context "with an invalid response" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building(CC_BUILDING_INVALID_XML, stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to false" do
      @status_parser.should_not be_building
    end
  end
end
