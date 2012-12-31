require 'spec_helper'

describe StatusFetcher::Job do
  describe "#perform" do
    let(:project) { double(:project) }

    it "retrieves statuses from the StatusFetcher" do
      StatusFetcher.should_receive(:retrieve_status_for).with project
      StatusFetcher.should_receive(:retrieve_velocity_for).with project
      project.should_receive(:set_next_poll)
      project.should_receive(:save!)

      StatusFetcher::Job.new(project).perform
    end

  end
end

describe StatusFetcher do
  describe "#fetch_all" do
    context "some projects don't need to be polled" do
      let(:project) { stub(:project) }
      let(:job_for_project) { stub(:delayed_job) }

      before do
        Project.stub_chain(:updateable, :find_each).and_yield(project)
        StatusFetcher::Job.stub(:new).with(project).and_return job_for_project
      end

      it "enqueues a job for each polling project" do
        Delayed::Job.should_receive(:enqueue).with job_for_project, priority: 1
        StatusFetcher.fetch_all
      end
    end
  end

  describe "#retrieve_status_for" do
    let(:payload) { double(Payload) }
    let(:project) { double(Project, fetch_payload: payload) }

    it 'asks the project updater to update the project' do
      ProjectUpdater.should_receive(:update).with(project)
      StatusFetcher.retrieve_status_for project
    end
  end

  describe "#retrieve_velocity_for" do
    context "when the project is a tracker_project?" do
      let(:project) { FactoryGirl.create :project, current_velocity: 5, stories_to_accept_count: 0, open_stories_count: 0, tracker_project_id: 1, tracker_auth_token: "token" }
      let(:current_velocity) { 20 }
      let(:stories_to_accept_count) { 5 }
      let(:open_stories_count) { 2 }
      let(:last_ten_velocities) { [1,2,3,4,5,6,7,8,9,10] }

      let(:tracker_api) { double :tracker_api, 
                            current_velocity: current_velocity, 
                            last_ten_velocities: last_ten_velocities,
                            stories_to_accept_count: stories_to_accept_count,
                            open_stories_count: open_stories_count
      }

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

      it "should set the stories_to_accept_count on the project" do
        StatusFetcher.retrieve_velocity_for(project)
        project.stories_to_accept_count.should == stories_to_accept_count
      end

      it "should set the open_stories_count on the project" do
        StatusFetcher.retrieve_velocity_for(project)
        project.open_stories_count.should == open_stories_count
      end

      it "should set the online status to true" do
        project.tracker_online.should == nil
        StatusFetcher.retrieve_velocity_for(project)
        project.tracker_online.should == true
      end

      context "when a connection failure occurs" do
        before do
          tracker_api.stub(:current_velocity).and_raise(RestClient::Unauthorized)
        end

        it "should set the online status to false" do
          StatusFetcher.retrieve_velocity_for(project)
          project.tracker_online.should == false
        end
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
