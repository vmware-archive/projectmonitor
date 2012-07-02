require 'spec_helper'

describe StatusFetcher do
  describe "#current_velocity_for" do
    let(:project) { FactoryGirl.create(:project, :current_velocity => 5) }
    let(:pt_project) { double(:pt_project, :current_velocity => 7) }

    before { PivotalTracker::Project.stub(:find).and_return(pt_project) }

    it "fetches the latest velocity for the project and stores it" do
      StatusFetcher.retrieve_velocity_for(project)
      project.current_velocity.should == 7
    end
  end
end
