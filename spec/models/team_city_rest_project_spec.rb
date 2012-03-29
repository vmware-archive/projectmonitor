require 'spec_helper'

describe TeamCityRestProject do

  context "TeamCity REST API feed" do
    let(:rest_url) { "http://foo.bar.com:3434/app/rest/builds?locator=running:all,buildType:(id:bt3)" }
    let(:project) { TeamCityRestProject.new(:name => "my_teamcity_project", :feed_url => rest_url) }

    describe "#feed_url" do
      context "with the personal flag" do
        ["true", "false", "any"].each do |flag|
          it "should be valid with #{flag}" do
            project.feed_url = "#{rest_url},personal:#{flag}"
            project.should be_valid
          end
        end
      end

      context "with the user option" do
        it "should be valid" do
          project.feed_url = "#{rest_url},user:some_user123"
          project.should be_valid
        end
      end

      context "with both the personal and user option" do
        it "should be valid" do
          project.feed_url = "#{rest_url},user:some_user123,personal:true"
          project.should be_valid
        end
      end
    end

    describe "#project_name" do
      it "should return nil when feed_url is nil" do
        project.feed_url = nil
        project.project_name.should be_nil
      end

      it "should return the feed url, since TeamCity does not have the project name in the feed_url" do
        project.project_name.should == project.feed_url
      end
    end

    describe "#build_status_url" do
      it "should use rest api" do
        project.build_status_url.should == rest_url
      end
    end

    describe "#parse_project_status" do

      describe "with reported success" do
        let :status_parser do
          project.parse_project_status(TeamcityRESTExample.new("success.xml").read)
        end

        it "should return the link to the checkin" do
          status_parser.url.should == TeamcityRESTExample.new("success.xml").first_css("build").attribute("webUrl").value
        end

        context "there is a previous status for the same build" do
          before do
            @published_at = Clock.now - 10.minutes
            project.stub(:statuses) {[
                ProjectStatus.new(:url => TeamcityRESTExample.new("success.xml").first_css("build").attribute("webUrl").value,
                                  :published_at => @published_at,
                                  :success => true, :online => true)
              ]}
          end

          it "should return the published date of the checkin" do
            status_parser.published_at.should == @published_at
          end
        end

        context "there is a previous status for another build" do
          before do
            project.stub(:statuses) {[
                ProjectStatus.new(:url => TeamcityRESTExample.new("success.xml").as_xml.css("build")[1].attribute("webUrl").value,
                                  :published_at => Clock.now - 10.minutes,
                                  :success => true, :online => true)
              ]}
          end

          it "should return the timestamp when we checked" do
            status_parser.published_at.should == Clock.now
          end
        end

        context "there is no previous status" do
          it "should return the timestamp when we checked" do
            status_parser.published_at.should == Clock.now
          end
        end

        it "should report success" do
          status_parser.should be_success
        end
      end

      describe "with a startDate included" do
        before(:each) do
          @status_parser = project.parse_project_status(TeamcityRESTExample.new("success_with_start_date.xml").read)
        end

        it "should return the published date of the checkin" do
          @status_parser.published_at.should ==
            Time.parse(TeamcityRESTExample.new("success_with_start_date.xml").first_css("build").attribute("startDate").value)
        end
      end

      describe "with reported failure" do
        before(:each) do
          @status_parser = project.parse_project_status(TeamcityRESTExample.new("failure.xml").read)
        end

        it "should return the link to the checkin" do
          @status_parser.url.should == TeamcityRESTExample.new("failure.xml").first_css("build").attribute("webUrl").value
        end

        it "should return the published date of the checkin" do
          @status_parser.published_at.should == Clock.now
        end

        it "should report failure" do
          @status_parser.should_not be_success
        end
      end

      describe "with invalid xml" do
        before(:each) do
          @parser        = Nokogiri::XML.parse(@response_xml = "<foo><bar>baz</bar></foo>")
          @response_doc  = @parser.parse
          @status_parser = project.parse_project_status("<foo><bar>baz</bar></foo>")
        end
      end
    end

    describe "#parse_building_status" do
      let(:project) { TeamCityRestProject.new(:name => "my_teamcity_project", :feed_url => "Pulse") }

      context "with a valid response that the project is building" do
        before(:each) do
          @status_parser = project.parse_building_status(BuildingStatusExample.new("team_city_rest_building.xml").read)
        end

        it "should set the building flag on the project to true" do
          @status_parser.should be_building
        end
      end

      context "with a valid response that the project is not building" do
        before(:each) do
          @status_parser = project.parse_building_status(BuildingStatusExample.new("team_city_rest_not_building.xml").read)
        end

        it "should set the building flag on the project to false" do
          @status_parser.should_not be_building
        end
      end

      context "with an invalid response" do
        before(:each) do
          @status_parser = project.parse_building_status("<foo><bar>baz</bar></foo>")
        end

        it "should set the building flag on the project to false" do
          @status_parser.should_not be_building
        end
      end
    end
  end
end
