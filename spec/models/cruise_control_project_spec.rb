require 'spec_helper'

describe Project do
  before(:each) do
    @project = CruiseControlProject.new(:name => "my_cc_project", :feed_url => "http://foo.bar.com:3434/projects/mystuff/baz.rss")
  end

  describe "validations" do
    describe "validation" do
      it "should require an RSS URL" do
        @project.feed_url = ""
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end

      it "should require that the RSS URL contain a valid domain" do
        @project.feed_url = "foo"
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end

      it "should require that the RSS URL contain a valid address" do
        @project.feed_url = "http://foo.bar.com/"
        @project.should_not be_valid
        @project.errors[:feed_url].should_not be_nil
      end
    end
  end
  
  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should extract the project name from the RSS url" do
      @project.project_name.should == "baz"
    end

    it "should extract the project name from the RSS url regardless of capitalization" do
      @project.feed_url = @project.feed_url.upcase
      @project.project_name.should == "BAZ"
    end
  end

  describe "status_parser" do
    describe "with reported success" do
      before(:each) do
        @status_parser = @project.parse_project_status(CCRssExample.new("success.rss").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == CCRssExample.new("success.rss").xpath_content("/rss/channel/item/link")
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should ==
            Time.parse(CCRssExample.new("success.rss").xpath_content("/rss/channel/item/pubDate")) 
      end

      it "should report success" do
        @status_parser.should be_success
      end
    end

    describe "with reported failure" do
      before(:each) do
        @status_parser = @project.parse_project_status(CCRssExample.new("failure.rss").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/link")
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/pubDate"))
      end

      it "should report failure" do
        @status_parser.should_not be_success
      end
    end

  #  describe "with invalid xml" do
  #    before(:all) do
  #      @parser = XML::Parser.string(@response_xml =  "<foo><bar>baz</bar></foo>")
  #      @response_doc = @parser.parse
  #      @status_parser = StatusParser.status( "<foo><bar>baz</bar></foo>")
  #    end
  #
  #    it "should report failure" do
  #      @status_parser.should_not be_success
  #    end
  #  end
  end


  describe "building_parser" do
    before(:each) do
      @project = CruiseControlProject.new(:name => "Socialitis", :feed_url => "http://foo.bar.com:3434/projects/Socialitis.rss")
    end
    
    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("socialitis_building.xml").read)
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("socialitis_not_building.xml").read)
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end

    context "with an invalid response" do
      before(:each) do
        @status_parser = @project.parse_building_status("<foo><bar>baz</bar></foo>")
      end

      it "should set the building flag on the project to false" do
        @status_parser.should_not be_building
      end
    end
  end
  
end
