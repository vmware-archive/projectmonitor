require 'spec_helper'

describe TrackerApi do
  context "with the real service", :vcr => {:re_record_interval => 18.months} do
    subject { TrackerApi.new(project) }

    # ALERT: Always use a fake tracker project with these tests because they delete everything!
    let(:project) { FactoryGirl.create :project, tracker_project_id: 688157, tracker_auth_token: "2b83dc74948d051bc1078fd6e9db0b3e" }
    let(:tracker_project) { PivotalTracker::Project.find project.tracker_project_id }

    before do
      PivotalTracker::Client.token = project.tracker_auth_token
      (1..3).each do |x|
        tracker_project.stories.create name: "Test #{x}",
          story_type: "feature",
          estimate: x,
          accepted_at: x.weeks.ago,
          current_state: "accepted",
          requested_by: "James Somers"
        tracker_project.stories.create name: "Test (delivered) #{x}",
          story_type: "feature",
          estimate: 0,
          current_state: "delivered",
          requested_by: "James Somers"
      end
      tracker_project.stories.create name: "Test (unstarted)",
        story_type: "feature",
        estimate: 0,
        current_state: "unstarted",
        requested_by: "James Somers"
    end

    after do
      tracker_project.stories.all.each(&:delete)
    end

    context "last_ten_velocities" do
      it "should be the sum of the estimates of the stories from the 10 most recent iterations" do
        subject.last_ten_velocities.should == [1,2,3]
      end

      context "when the current iterations has unaccepted stories" do
        it "does not count the unaccepted stories" do
          tracker_project.stories.create name: "Test (started)",
            story_type: "feature",
            estimate: 3,
            current_state: "started",
            requested_by: "James Somers"

          subject.last_ten_velocities.should == [1,2,3]
        end
      end
    end

    context "stories_to_accept_count" do
      it "returns the number of delivered stories in the current iteration" do
        subject.stories_to_accept_count.should == 3
      end
    end

    context "open_stories_count" do
      it "returns the number of unstarted stories in the current iteration" do
        subject.open_stories_count.should == 1
      end
    end
  end
end
