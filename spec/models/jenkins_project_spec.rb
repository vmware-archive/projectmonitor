require 'spec_helper'

describe JenkinsProject do
  before(:each) do
    @project = JenkinsProject.new(:name => "my_jenkins_project", :feed_url => "http://foo.bar.com:3434/job/example_project/rssAll")
  end

  it_should_behave_like 'a project that updates only the most recent status'

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
    it "should require a Jenkins url format" do
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/wrong/example_project/rssAll'
      @project.should have(1).errors_on(:feed_url)
      @project.feed_url = 'http://foo.bar.com:3434/job/example_project/wrong'
      @project.should have(1).errors_on(:feed_url)
    end

    it "should allow both http and https" do
      @project.feed_url = "http://foo.bar.com:3434/job/example_project/rssAll"
      @project.should have(0).errors_on(:feed_url)
      @project.feed_url = 'https://foo.bar.com:3434/job/example_project/rssAll'
      @project.should have(0).errors_on(:feed_url)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      @project.build_status_url.should == "http://foo.bar.com:3434/cc.xml"
    end
  end

  describe "#status_parser" do
    shared_examples_for "successful build" do
      before(:each) do
        @status_parser = @project.parse_project_status(JenkinsAtomExample.new(@feed_file).read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == JenkinsAtomExample.new(@feed_file).first_css("entry:first link").attribute('href').value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(JenkinsAtomExample.new(@feed_file).first_css("entry:first published").content)
      end

      it "should report success" do
        @status_parser.should be_success
      end
    end
    
    describe "with reported 'success'" do
      before(:each) do
        @feed_file = "success.atom"
      end

      it_should_behave_like "successful build"
    end

    describe "with reported 'stable'" do
      before(:each) do
        @feed_file = "stable.atom"
      end

      it_should_behave_like "successful build"
    end

    describe "with reported 'back to normal'" do
      before(:each) do
        @feed_file = "back_to_normal.atom"
      end

      it_should_behave_like "successful build"
    end

    describe "with reported failure" do
      before(:each) do
        @status_parser = @project.parse_project_status(JenkinsAtomExample.new("failure.atom").read)
      end

      it "should return the link to the checkin" do
        @status_parser.url.should == JenkinsAtomExample.new("failure.atom").first_css("entry:first link").attribute('href').value
      end

      it "should return the published date of the checkin" do
        @status_parser.published_at.should == Time.parse(JenkinsAtomExample.new("failure.atom").first_css("entry:first published").content)
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
      @project = JenkinsProject.new(:name => "CiMonitor", :feed_url => "http://foo.bar.com:3434/job/CiMonitor/rssAll")
    end

    context "with a valid response that the project is building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("jenkins_cimonitor_building.atom").read)
      end

      it "should set the building flag on the project to true" do
        @status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      before(:each) do
        @status_parser = @project.parse_building_status(BuildingStatusExample.new("jenkins_cimonitor_not_building.atom").read)
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
