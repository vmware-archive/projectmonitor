require 'spec_helper'

describe TrackerApi do
  describe "last_ten_velocities" do
    before do
      PivotalTracker::Iteration.stub(:current).and_return(current_iteration)
      PivotalTracker::Iteration.stub(:done).and_return(done_iterations)
      PivotalTracker::Project.stub(:find)
    end

    let(:project) { double(:project, :tracker_project_id => 1, :tracker_auth_token => 2) }

    let(:current_iteration) do
      double(:iteration, :stories => [
        double(:story, :estimate => 20, :current_state => "started"),
        double(:story, :estimate => 21, :current_state => "accepted")
      ])
    end

    let(:done_iterations) do
      [
        double(:iteration, :stories => [ double(:story, :estimate => 0), double(:story, :estimate => 0) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 0), double(:story, :estimate => 1) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 2), double(:story, :estimate => 3) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 4), double(:story, :estimate => 5) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 6), double(:story, :estimate => 7) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 8), double(:story, :estimate => 9) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 10), double(:story, :estimate => 11) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 12), double(:story, :estimate => 13) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 14), double(:story, :estimate => 15) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 16), double(:story, :estimate => 17) ]),
        double(:iteration, :stories => [ double(:story, :estimate => 18), double(:story, :estimate => 19) ])
      ]
    end

    it "should be the sum of the estimates of the stories from the prior 10 iterations in reverse order" do
      TrackerApi.new(project).last_ten_velocities.should == [37, 33, 29, 25, 21, 17, 13, 9, 5, 1]
    end
  end
end
