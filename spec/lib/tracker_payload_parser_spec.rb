require 'spec_helper'

describe TrackerPayloadParser do

  let(:project_payload) { File.read('spec/fixtures/tracker_api_examples/project_payload.xml') }
  let(:current_iteration_payload) { File.read('spec/fixtures/tracker_api_examples/current_iteration_payload.xml') }
  let(:iterations_payload) { File.read('spec/fixtures/tracker_api_examples/iterations_payload.xml') }

  subject { TrackerPayloadParser.new(project_payload, current_iteration_payload, iterations_payload) }

  describe '#current_velocity' do
    subject { super().current_velocity }
    it { is_expected.to eq(5) }
  end

  describe '#last_ten_velocities' do
    subject { super().last_ten_velocities }
    it { is_expected.to eq([13, 4, 2, 9, 0, 5, 7, 8, 5, 5]) }
  end

  describe '#iteration_story_state_counts' do
    subject { super().iteration_story_state_counts }
    it do
    is_expected.to eq([
      { "label" => "unstarted", "value" => 7, },
      { "label" => "started", "value" => 2, },
      { "label" => "finished", "value" => 0, },
      { "label" => "delivered", "value" => 8, },
      { "label" => "accepted", "value" => 13, },
      { "label" => "rejected", "value" => 0, },
    ])
  end
  end
end
