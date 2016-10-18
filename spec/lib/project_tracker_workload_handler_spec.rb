require 'spec_helper'

describe ProjectTrackerWorkloadHandler do

  let(:project) { double(:project) }

  subject { ProjectTrackerWorkloadHandler.new(project) }

  describe '#workload_complete' do
    let(:project_payload) { double(:project_payload) }
    let(:current_iteration_payload) { double(:current_iteration_payload) }
    let(:iterations_payload) { double(:iterations_payload) }

    it 'should update the projects tracker metrics' do
      allow(TrackerPayloadParser).to receive(:new).with(project_payload, current_iteration_payload, iterations_payload).and_return(
          double(TrackerPayloadParser,
                 current_velocity: 1,
                 last_ten_velocities:[1,2,3],
                 iteration_story_state_counts:[{stories: 'are awesome'}]
          ))

      expect(project).to receive(:tracker_online=).with(true)
      expect(project).to receive(:current_velocity=).with(1)
      expect(project).to receive(:last_ten_velocities=).with([1,2,3])
      expect(project).to receive(:iteration_story_state_counts=).with([{stories: 'are awesome'}])
      expect(project).to receive(:save!)

      subject.workload_complete({
                                    project: project_payload,
                                    current_iteration: current_iteration_payload,
                                    iterations: iterations_payload
                                })
    end
  end

  describe '#workload_failed' do
    it 'should mark the projects tracker status to offline' do
      expect(project).to receive(:tracker_online=).with(false)
      expect(project).to receive(:save!)

      subject.workload_failed(nil)
    end
  end

end