require 'spec_helper'

describe TeamCityRestProject do

  context "TeamCity REST API feed" do
    let(:rest_url) { "http://foo.bar.com:3434/app/rest/builds?locator=running:all,buildType:(id:bt3)" }
    let(:project) { TeamCityRestProject.new(:name => "my_teamcity_project", :feed_url => rest_url) }

    describe "#fetch_new_statuses" do
      before do
        project.save!
        UrlRetriever.stub(:retrieve_content_at).and_return xml_text
      end

      def fetch_new_statuses
        project.fetch_new_statuses
      end


      context "when there are no builds" do
        let(:xml_text) {
          <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="0"/>
          XML
        }

        it "does not add any statuses" do
          expect { fetch_new_statuses }.to_not change(project.statuses, :count)
        end
      end

      context "when there is a new build" do
        let(:url) { '/1' }
        let(:start_time) { 5.minutes.ago }
        let(:status) { '' }

        let(:xml_text) {
          <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="#{status}" webUrl="#{url}" startDate="#{start_time.iso8601}" />
          </builds>
          XML
        }

        it "creates a new status" do
          expect { fetch_new_statuses }.to change(project.statuses, :count).by(1)
        end

        it "gives the status the correct time" do
          fetch_new_statuses
          project.status.published_at.to_i.should == start_time.to_i
        end

        it "gives the status the correct url" do
          fetch_new_statuses
          project.status.url.should == url
        end

        context "and the build is successful" do
          let(:status) { 'SUCCESS' }

          it "creates a successful status" do
            fetch_new_statuses
            project.status.should be_success
          end
        end

        context "and the build is a failure" do
          let(:status) { 'FAILURE' }

          it "creates an unsuccessful status" do
            fetch_new_statuses
            project.status.should_not be_success
          end
        end
      end

      context "with multiple new builds" do
        before do
          project.statuses.create(url: '/1', success: true)
        end

        let(:xml_text) {
          <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="3">
            <build id="3" number="3" status="SUCCESS" webUrl="/3"  />
            <build id="2" number="2" status="SUCCESS" webUrl="/2"  />
            <build id="1" number="1" status="SUCCESS" webUrl="/1"  />
          </builds>
          XML
        }

        it "adds the new statuses" do
          fetch_new_statuses
          project.statuses.find_by_url('/3').should be
          project.statuses.find_by_url('/2').should be
        end

        it "doesn't add a duplicate of the existing status" do
          expect { fetch_new_statuses }.
            to_not change { project.statuses.find_all_by_url("/1").count }
        end
      end

      context "when a failing build is still in progress" do
        let(:xml_text) {
          <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="FAILURE" webUrl="/1" running="true" />
          </builds>
          XML
        }

        it "creates a status" do
          expect { fetch_new_statuses }.to change(project.statuses, :count).by(1)
        end
      end

      context "when a succeeding build is still in progress" do
        let(:xml_text) {
          <<-XML.strip_heredoc
          <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
          <builds count="1">
            <build id="1" number="1" status="SUCCESS" webUrl="/1" running="true" />
          </builds>
          XML
        }

        it "does not create a status" do
          expect { fetch_new_statuses }.to_not change(project.statuses, :count)
        end
      end
    end

    describe "#build_id" do
      it "is retrieved from the feed_url" do
        project.build_id.should == "bt3"
      end
    end

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
