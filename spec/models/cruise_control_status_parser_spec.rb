require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))
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

  describe "with reported success" do
    before(:all) do
      @parser = XML::Parser.string(@response_xml = CCRssExample.new("success.rss"))
      @response_doc = @parser.parse
      @status_parser = CruiseControlStatusParser.status(CCRssExample.new("success.rss"))
    end

    it_should_behave_like "cc status for a valid build history xml response"

    it "should report success" do
      @status_parser.should be_success
    end
  end

  describe "with reported failure" do
    before(:all) do
      @parser = XML::Parser.string(@response_xml = CCRssExample.new("failure.rss"))
      @response_doc = @parser.parse
      @status_parser = CruiseControlStatusParser.status(CCRssExample.new("failure.rss"))
    end

    it_should_behave_like "cc status for a valid build history xml response"

    it "should report failure" do
      @status_parser.should_not be_success
    end
  end

#  describe "with invalid xml" do
#    before(:all) do
#      @parser = XML::Parser.string(@response_xml =  "<foo><bar>baz</bar></foo>")
#      @response_doc = @parser.parse
#      @status_parser = CruiseControlStatusParser.status( "<foo><bar>baz</bar></foo>")
#    end
#
#    it "should report failure" do
#      @status_parser.should_not be_success
#    end
#  end
end

describe "building" do
  context "with a valid response that the project is building" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building(BuildingStatusExample.new("socialitis_building.xml"), stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to true" do
      @status_parser.should be_building
    end
  end

  context "with a valid response that the project is not building" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building(BuildingStatusExample.new("socialitis_not_building.xml"), stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to false" do
      @status_parser.should_not be_building
    end
  end

  context "with an invalid response" do
    before(:each) do
      @status_parser = CruiseControlStatusParser.building("<foo><bar>baz</bar></foo>", stub("a project", :project_name => 'Socialitis'))
    end

    it "should set the building flag on the project to false" do
      @status_parser.should_not be_building
    end
  end
end
