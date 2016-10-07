require 'spec_helper'

describe ProjectTrackerWorkloadHandler do

  let(:project) { double(:project) }

  subject { ProjectTrackerWorkloadHandler.new(project) }

  describe '#workload_failed' do
    it 'should mark the projects tracker status to offline' do
      expect(project).to receive(:tracker_online=).with(false)
      expect(project).to receive(:save!)

      subject.workload_failed(nil)
    end
  end

end