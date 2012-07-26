require 'spec_helper'

describe ProjectContentFetcher do
  let(:project) { FactoryGirl.create(:team_city_rest_project) }
  let(:payload) { double(Payload).as_null_object }
  let(:project_content_fetcher) { ProjectContentFetcher.new(project, payload) }

  before do
    UrlRetriever.stub(:retrieve_content_at).and_return("foo", "bar")
    project.stub(feed_url: "foo", auth_username: nil, auth_password: nil)
  end

  describe "#fetch" do
    subject { project_content_fetcher.fetch }

    context "when the project only has a feed_url" do
      it "retrieves content using the feed_url" do
        project_content_fetcher.should_receive :fetch_status
        subject
      end

      it "does not retrieve content using the build_status_url" do
        project_content_fetcher.should_not_receive :fetch_building_status
        subject
      end

      it "sets #status_content on the payload" do
        payload.should_receive(:status_content=).with("foo")
        subject
      end

      context "and retrieving on feed_url causes HTTPError" do
        it "marks project as offline and not building" do
          UrlRetriever.stub(:retrieve_content_at).with("foo",nil, nil).and_raise Net::HTTPError.new("error", 500)
          project.should_receive(:offline!)
          project.should_receive(:not_building!)
          subject
        end
      end
    end

    context "when the project has a feed_url and a build_status_url" do
      let(:project) { FactoryGirl.create(:jenkins_project) }

      before { project.stub(build_status_url: "bar") }

      it "retrieves content using the feed_url" do
        project_content_fetcher.should_receive :fetch_status
        subject
      end

      it "retrieves content using the build_status_url" do
        project_content_fetcher.should_receive :fetch_building_status
        subject
      end

      it "sets #status_content on the payload" do
        payload.should_receive(:status_content=).with("foo")
        subject
      end

      it "sets #build_status_content on the payload" do
        payload.should_receive(:build_status_content=).with("bar")
        subject
      end

      context "and retrieving on feed_url causes HTTPError" do
        it "marks project as offline" do
          UrlRetriever.stub(:retrieve_content_at).with("foo",nil,nil).and_raise(Net::HTTPError.new("error", 500))

          project.should_receive(:offline!)
          project.should_not_receive(:not_building!)

          subject
        end
      end

      context "and retrieving on build_status_url causes HTTPError" do
        it "marks project as not building" do
          UrlRetriever.stub(:retrieve_content_at).with("bar",nil,nil).and_raise(Net::HTTPError.new("error", 500))

          project.should_not_receive(:offline!)
          project.should_receive(:not_building!)

          subject
        end
      end
    end
  end
end
