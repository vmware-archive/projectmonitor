require 'spec_helper'

describe TravisProject do
  let(:project) { TravisProject.new(:name => "my_travis_project", :feed_url => "http://travis-ci.org/pivotal/projectmonitor/cc.xml") }

  it_should_behave_like 'a project that updates only the most recent status'

  describe "#project_name" do
    it "should return nil when feed_url is nil" do
      project.feed_url = nil
      project.project_name.should be_nil
    end

    it "should extract the project name from the feed url" do
      project.project_name.should == "projectmonitor"
    end
  end

  describe 'validations' do
    it "should require a Travis url format" do
      project.should have(0).errors_on(:feed_url)
      project.feed_url = 'http://foo/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
      project.feed_url = 'http://travis-ci.org/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
      project.feed_url = 'http://travis-ci.org/#!/pivotal/projectmonitor'
      project.should have(1).errors_on(:feed_url)
    end

    it "should allow both http and https" do
      project.feed_url = "http://travis-ci.org/pivotal/projectmonitor/cc.xml"
      project.should have(0).errors_on(:feed_url)
      project.feed_url = 'https://travis-ci.org/pivotal/projectmonitor/cc.xml'
      project.should have(0).errors_on(:feed_url)
    end
  end

  describe "#build_status_url" do
    it "should use cc.xml" do
      project.build_status_url.should == "http://travis-ci.org/pivotal/projectmonitor/cc.xml"
    end
  end

  describe "#status_parser" do
    describe "with reported 'success'" do
      let(:example) { TravisExample.new("success.xml") }
      let(:status_parser) { project.parse_project_status(example.read) }

      it "should return the link to the checkin" do
        status_parser.url.should == example.first_css("Project").attribute('webUrl').value
      end

      it "should return the published date of the checkin" do
        status_parser.published_at.should == Time.parse(example.first_css("Project").attribute("lastBuildTime").value)
      end

      it "should report success" do
        status_parser.should be_success
      end
    end

    describe "with reported failure" do
      let(:example) { TravisExample.new("failure.xml") }
      let(:status_parser) { project.parse_project_status(example.read) }

      it "should return the link to the checkin" do
        status_parser.url.should == example.first_css("Project").attribute('webUrl').value
      end

      it "should return the published date of the checkin" do
        status_parser.published_at.should == Time.parse(example.first_css("Project").attribute("lastBuildTime").value)
      end

      it "should report failure" do
        status_parser.should_not be_success
      end
    end
  end

  describe "#building_parser" do
    context "with a valid response that the project is building" do
      let(:example) { TravisExample.new("building.xml") }
      let(:status_parser) { project.parse_building_status(example.read) }

      it "should set the building flag on the project to true" do
        status_parser.should be_building
      end
    end

    context "with a valid response that the project is not building" do
      let(:example) { TravisExample.new("sleeping.xml") }
      let(:status_parser) { project.parse_building_status(example.read) }

      it "should set the building flag on the project to false" do
        status_parser.should_not be_building
      end
    end

    context "with an invalid response" do
      let(:status_parser) { project.parse_building_status("<foo><bar>baz</bar></foo>") }

      it "should set the building flag on the project to false" do
        status_parser.should_not be_building
      end
    end
  end
end
