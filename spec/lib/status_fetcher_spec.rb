require 'spec_helper'

describe StatusFetcher::Job do
  describe "#perform" do
    let(:project) { double(:project) }

    it "retrieves statuses from the StatusFetcher" do
      StatusFetcher.should_receive(:retrieve_status_for).with project
      StatusFetcher.should_receive(:retrieve_building_status_for).with project
      StatusFetcher.should_receive(:retrieve_velocity_for).with project
      project.should_receive(:set_next_poll!)

      StatusFetcher::Job.new(project).perform
    end

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
      project.should_receive(:fetch_new_statuses)
      subject
    end

    context "project status can not be retrieved from remote source" do
      let(:project_status) { double('project_status') }
      before do
        project.stub(:fetch_new_statuses).and_raise Net::HTTPError.new("can't do it", 500)
        project.stub(:status).and_return project_status
      end

      context "a status does not exist with the error that is returned" do
        before do
          project_status.stub(:error).and_return "another error"
        end

        it "creates a status with the error message" do
          project.statuses.should_receive(:create)
          StatusFetcher.retrieve_status_for(project)
        end
      end

      context "a status exists with the error that is returned" do
        before do
          project_status.stub(:error).and_return "HTTP Error retrieving status for project '##{project.id}': can't do it"
        end

        it "does not create a duplicate status" do
          project.statuses.should_not_receive(:create)
          StatusFetcher.retrieve_status_for(project)
        end
      end
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
        project.stub(:fetch_building_status).and_return status
        StatusFetcher.retrieve_building_status_for project
      end

      it { should == building_status }
    end

    context "project status can not be retrieved" do
      before do
        project.stub(:fetch_building_status).and_raise Net::HTTPError.new("can't do it", 500)
        StatusFetcher.retrieve_building_status_for project
      end

      it { should be_false }
    end
  end

  describe "#retrieve_velocity_for" do
    context "when the project is a tracker_project?" do
      let(:project) { FactoryGirl.create :project, current_velocity: 5, tracker_project_id: 1, tracker_auth_token: "token" }
      let(:current_velocity) { 20 }
      let(:last_ten_velocities) { [1,2,3,4,5,6,7,8,9,10] }

      let(:tracker_api) { double :tracker_api, :current_velocity => current_velocity, :last_ten_velocities => last_ten_velocities }

      before do
        TrackerApi.stub(:new).and_return tracker_api
      end

      it "should set the last_ten_velocities on the project" do
        StatusFetcher.retrieve_velocity_for(project)
        project.last_ten_velocities.should == last_ten_velocities
      end

      it "should set the current_velocity on the project" do
        StatusFetcher.retrieve_velocity_for(project)
        project.current_velocity.should == current_velocity
      end
    end

    context "when the project is not a tracker_project?" do
      let(:project) { FactoryGirl.create :project }

      it "should do nothing" do
        project.should_not_receive :current_velocity=
        project.should_not_receive :last_ten_velocities=

        StatusFetcher.retrieve_velocity_for(project)
      end
    end
  end
end
