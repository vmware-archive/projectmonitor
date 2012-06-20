require 'spec_helper'

describe StatusFetcher::Job do
  describe "#perform" do
    let(:project) { double(:project) }

    before do
      StatusFetcher.should_receive(:retrieve_status_for).with project
      StatusFetcher.should_receive(:retrieve_building_status_for).with project
      StatusFetcher.should_receive(:retrieve_tracker_status_for).with project
      project.should_receive(:set_next_poll!).and_return true
    end

    subject { StatusFetcher::Job.new(project).perform }

    it { should be_true }
  end
end

describe StatusFetcher do
  describe "#fetch_all" do
    context "some projects don't need to be polled" do
      let(:project) { stub(:project, needs_poll?: true) }
      let(:non_polling_project) { stub(:project, needs_poll?: false) }
      let(:projects) { [project, non_polling_project] }

      let(:job_for_project) { stub(:delayed_job) }
      let(:job_for_non_polling_project) { stub(:unexpected_delayed_job) }

      before do
        Project.stub(:all).and_return projects
        StatusFetcher::Job.stub(:new).with(project).and_return job_for_project
        StatusFetcher::Job.stub(:new).with(non_polling_project).and_return job_for_non_polling_project
      end

      it "enqueues a job for each polling project" do
        Delayed::Job.should_receive(:enqueue).with job_for_project
        StatusFetcher.fetch_all
      end

      it "does not enqueue a job for a project which doesn't need to poll" do
        Delayed::Job.should_not_receive(:enqueue).with job_for_non_polling_project
        StatusFetcher.fetch_all
      end
    end
  end

  describe "#retrieve_status_for" do
    let(:project) { Project.new }
    let(:content) { double(:xml_content) }
    let(:status)  { ProjectStatus.new }

    subject { StatusFetcher.retrieve_status_for project }

    it "delegates status update to the project" do
      project.should_receive(:process_status_update)
      subject
    end

  end

  describe "#retrieve_building_status_for" do
    let(:project) { Project.new }
    let(:content) { double(:content) }
    let(:building_status) { [true, false].sample }
    let(:status) { double(:status, :building? => building_status )}

    subject do
      project.building
    end

    context "project status can be retrieved from the remote source" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_return content
        project.should_receive(:parse_building_status).with(content).and_return status
        StatusFetcher.retrieve_building_status_for project
      end

      it { should == building_status }
    end

    context "project status can not be retrieved" do
      before do
        UrlRetriever.stub(:retrieve_content_at).and_raise Net::HTTPError.new("can't do it", 500)
        StatusFetcher.retrieve_building_status_for project
      end

      it { should be_false }
    end
  end

  describe "#retrieve_tracker_status_for" do
    let(:project) { Project.new }
    # StatusFetcher.retrieve_tracker_status_for(project)

    describe "#update_tracker_status!" do
      context "no tracker configuration" do
        let(:project) { Project.new }

        it "doesn't do anything with the TrackerApi" do
          TrackerApi.should_not_receive(:new)
          StatusFetcher.retrieve_tracker_status_for(project)
        end
      end

      context "with tracker configuration" do
        let(:project) { Project.new tracker_project_id: 1, tracker_auth_token: "token"}
        let(:tracker_api) { double :tracker_api_instance }

        before do
          TrackerApi.stub(:new).with(project.tracker_auth_token).and_return tracker_api
          tracker_api.stub(:delivered_story_count).with(project.tracker_project_id).and_return 7
        end

        it "should set the project's tracker_num_unaccepted_stories to the number of delivered stories" do
          StatusFetcher.retrieve_tracker_status_for(project)
          project.tracker_num_unaccepted_stories.should == 7
        end
      end
    end
  end
end
