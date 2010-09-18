require File.expand_path(File.join(File.dirname(__FILE__),'..','spec_helper'))

describe HudsonProject do
  before(:each) do
    @project = HudsonProject.new(:name => "my_hudson_project", :feed_url => "http://foo.bar.com:3434/job/example_project/rssAll")
  end
  
  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      @project.feed_url = nil
      @project.project_name.should be_nil
    end

    it "should extract the project name from the Atom url" do
      @project.project_name.should == "example_project"
    end

    it "should extract the project name from the Atom url regardless of capitalization" do
      @project.feed_url = @project.feed_url.upcase
      @project.project_name.should == "EXAMPLE_PROJECT"
    end
  end

  describe 'validations' do
    it "should require a Hudson url format" do
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/wrong/example_project/rssAll'
      @project.should have(1).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/job/example_project/wrong'
      @project.should have(1).errors_on(:feed_url)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/cc.xml"
    end
  end

  describe "#status_parser" do
    describe "with reported success" do
      before(:each) do
        @status_parser = @project.parse_project_status(HudsonAtomExample.new("success.atom").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == HudsonAtomExample.new("success.atom").first_css("entry:first link").attribute('href').value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(HudsonAtomExample.new("success.atom").first_css("entry:first published").content)
      end

      it "should report success" do
        @status_parser.should be_success
      end
    end

    describe "with reported failure" do
      before(:each) do
        @status_parser = @project.parse_project_status(HudsonAtomExample.new("failure.atom").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == HudsonAtomExample.new("failure.atom").first_css("entry:first link").attribute('href').value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(HudsonAtomExample.new("failure.atom").first_css("entry:first published").content)
      end

      it "should report failure" do
        @status_parser.should_not be_success
      end
    end

    describe "with invalid xml" do
      before(:each) do
        @parser = Nokogiri::XML.parse(@response_xml = "<foo><bar>baz</bar></foo>")
        @response_doc = @parser.parse
        @status_parser = @project.parse_project_status("<foo><bar>baz</bar></foo>")
      end
    end
  end
  
  describe "#building_parser" do
    before(:each) do
      @project = HudsonProject.new(:name => "CiMonitor", :feed_url => "http://foo.bar.com:3434/job/CiMonitor/rssAll")
    end

    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("hudson_cimonitor_building.atom").read)
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("hudson_cimonitor_not_building.atom").read)
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
