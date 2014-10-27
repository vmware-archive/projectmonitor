require 'spec_helper'

describe TrackerApi do
  describe "last_ten_velocities" do
    before do
      allow(PivotalTracker::Iteration).to receive(:current).and_return(current_iteration)
      allow(PivotalTracker::Iteration).to receive(:done).and_return(done_iterations)
      allow(PivotalTracker::Project).to receive(:find)
    end

    let(:project) { double(:project, tracker_project_id: 1, tracker_auth_token: 2) }

    let(:current_iteration) do
      double(:iteration, stories: [
        double(:story, estimate: 20, current_state: "started"),
        double(:story, estimate: 21, current_state: "accepted")
      ])
    end

    let(:done_iterations) do
      [
        double(:iteration, stories: [ double(:story, estimate: 0), double(:story, estimate: 0) ]),
        double(:iteration, stories: [ double(:story, estimate: 0), double(:story, estimate: 1) ]),
        double(:iteration, stories: [ double(:story, estimate: 2), double(:story, estimate: 3) ]),
        double(:iteration, stories: [ double(:story, estimate: 4), double(:story, estimate: 5) ]),
        double(:iteration, stories: [ double(:story, estimate: 6), double(:story, estimate: 7) ]),
        double(:iteration, stories: [ double(:story, estimate: 8), double(:story, estimate: 9) ]),
        double(:iteration, stories: [ double(:story, estimate: 10), double(:story, estimate: 11) ]),
        double(:iteration, stories: [ double(:story, estimate: 12), double(:story, estimate: 13) ]),
        double(:iteration, stories: [ double(:story, estimate: 14), double(:story, estimate: 15) ]),
        double(:iteration, stories: [ double(:story, estimate: 16), double(:story, estimate: 17) ]),
        double(:iteration, stories: [ double(:story, estimate: 18), double(:story, estimate: 19) ])
      ]
    end

    it "should be the sum of the estimates of the stories from the prior 10 iterations in reverse order" do
      expect(TrackerApi.new(project).last_ten_velocities).to eq([37, 33, 29, 25, 21, 17, 13, 9, 5, 1])
    end

    it "should not include the sum of the estimate for the current iteration" do
      expect(TrackerApi.new(project).last_ten_velocities).not_to include(20 + 21)
    end
  end
end
