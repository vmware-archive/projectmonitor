require 'spec_helper'

describe TrackerApi do
  context "with the real service", :vcr => {:re_record_interval => 7.days} do
    let(:project) { FactoryGirl.create :project, tracker_project_id: 590337, tracker_auth_token: "881c7bc3264a00d280225ea409225fe8" }
    let(:tracker_project) { PivotalTracker::Project.find project.tracker_project_id }

    before do
      PivotalTracker::Client.token = project.tracker_auth_token
      (1..3).each do |x|
        x.times do
          tracker_project.stories.create :name => "Test #{x}",
                                         :story_type => "feature",
                                         :estimate => 1,
                                         :accepted_at => x.weeks.ago,
                                         :current_state => "accepted"

        end
      end
    end

    after do
      tracker_project.stories.all.each &:delete
    end

    context "last_ten_velocities" do
      it "should be the sum of the estimates of the stories from the prior 10 iterations in reverse order" do
        TrackerApi.new(project).last_ten_velocities.should == [1,2,3]
      end
    end
  end
end
