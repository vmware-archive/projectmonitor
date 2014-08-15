require 'spec_helper'

describe TrackerPayloadParser do

  let(:project_payload) { File.read('spec/fixtures/tracker_api_examples/project_payload.xml') }
  let(:current_iteration_payload) { File.read('spec/fixtures/tracker_api_examples/current_iteration_payload.xml') }
  let(:iterations_payload) { File.read('spec/fixtures/tracker_api_examples/iterations_payload.xml') }

  subject { TrackerPayloadParser.new(project_payload, current_iteration_payload, iterations_payload) }

  its(:current_velocity) { should == 5 }
  its(:last_ten_velocities) { should == [13, 4, 2, 9, 0, 5, 7, 8, 5, 5] }
  its(:iteration_story_state_counts) do
    should == [
      { "label" => "unstarted", "value" => 7, },
      { "label" => "started", "value" => 2, },
      { "label" => "finished", "value" => 0, },
      { "label" => "delivered", "value" => 8, },
      { "label" => "accepted", "value" => 13, },
      { "label" => "rejected", "value" => 0, },
    ]
  end
end
