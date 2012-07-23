require 'spec_helper'

describe ProjectContentFetcher do
  let(:project) { FactoryGirl.create(:team_city_rest_project) }
  let(:project_content_fetcher) { ProjectContentFetcher.new(project) }
  subject { project_content_fetcher.fetch }
  describe "#fetch" do
    context "when the project only has a feed_url" do
      before do
        UrlRetriever.stub(:retrieve_content_at)
      end

      it "retrieves content using the feed_url" do
        project_content_fetcher.should_receive :fetch_status
        subject
      end

      it "does not retrieve content using the build_status_url" do
        project_content_fetcher.should_not_receive :fetch_building_status
        subject
      end

      context "and retrieving on feed_url causes HTTPError" do
        let(:message) { "error" }
        it "adds an error status" do
          UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new(message, 500)
          project.statuses.should_receive(:create!)
          subject
        end
      end

      context "project status can not be retrieved from remote source" do
        let(:project_status) { double('project_status', error: "") }
        before do
          UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
          project.stub(:status).and_return project_status
          subject
        end

        context "a status does not exist with the error that is returned" do
          before do
            project_status.stub(:error).and_return "another error"
          end

          it "creates a status with the error message" do
            project.statuses.should_receive(:create!)
            StatusFetcher.retrieve_status_for(project)
            subject
          end
        end

        context "a status exists with the error that is returned" do
          before do
            project_status.stub(:error).and_return "HTTP Error retrieving status for project '##{project.id}': can't do it"
          end

          it "does not create a duplicate status" do
            project.statuses.should_not_receive(:create)
            StatusFetcher.retrieve_status_for(project)
            subject
          end
        end
      end
    end

    context "when the project has a feed_url and a build_status_url" do
      let(:project) { FactoryGirl.create(:jenkins_project) }
      let(:build_url) {"http://foo.com"}
      before do
        UrlRetriever.stub(:retrieve_content_at)
        project.stub(:build_status_url).and_return(build_url)
      end

      it "retrieves content using the feed_url" do
        project_content_fetcher.should_receive :fetch_status
        subject
      end

      it "retrieves content using the build_status_url" do
        project_content_fetcher.should_receive :fetch_building_status
        subject
      end

      it "combines the content from both urls" do
        project_content_fetcher.stub(:fetch_status) { 1 }
        project_content_fetcher.stub(:fetch_building_status) { 2 }
        subject.should == [1,2]
      end

      describe "#retrieve_status_for" do
        let(:content) { double(:content) }
        let(:building_status) { false }
        let(:status) { double(:status, :building? => building_status )}

        subject do
          project.building
        end

        context "project status can be retrieved from the remote source" do
          before do
            UrlRetriever.stub(:retrieve_content_at)
            StatusFetcher.retrieve_status_for project
          end

          it { should == building_status }
        end

        context "project status can not be retrieved" do
          before do
            UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
            StatusFetcher.retrieve_status_for project
          end

          it { should be_false }
        end
      end
    end
  end
end
