require 'spec_helper'

describe StatusFetcher do
  describe "#current_velocity_for" do
    let(:project) { FactoryGirl.create(:project, current_velocity: 5, tracker_project_id: 1, tracker_auth_token: "token") }
    let(:pt_project) { double(:pt_project, current_velocity: 7) }
    let(:iterations) do
      [
        double(:too_old_iteration),
        double(:too_old_iteration),
        double(:iteration, :stories => [double(:story, :estimate => 3)]),
        double(:iteration, :stories => [double(:story, :estimate => 3)]),
        double(:iteration, :stories => [double(:story, :estimate => 2)]),
        double(:iteration, :stories => [double(:story, :estimate => 3)]),
        double(:iteration, :stories => [double(:story, :estimate => 5)]),
        double(:iteration, :stories => [double(:story, :estimate => 1)]),
        double(:iteration, :stories => [double(:story, :estimate => 2)]),
        double(:iteration, :stories => [double(:story, :estimate => 4)]),
        double(:iteration, :stories => [double(:story, :estimate => 3), double(:story, :estimate => nil)]),
        double(:iteration, :stories => [double(:story, :estimate => 2), double(:story, :estimate => 2)]),
      ]
    end

    before do
      PivotalTracker::Project.stub(:find).and_return(pt_project)
      PivotalTracker::Iteration.stub(:done).and_return(iterations)
    end

    it "fetches the latest velocity for the project and stores it" do
      StatusFetcher.retrieve_velocity_for(project)
      project.current_velocity.should == 7
    end

    it "fetches the velocities from the last 10 completed iterations and stores them" do
      StatusFetcher.retrieve_velocity_for(project)
      project.last_ten_velocities.should == [4,3,4,2,1,5,3,2,3,3]
    end
  end
end
