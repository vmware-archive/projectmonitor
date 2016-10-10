require 'spec_helper'

describe TrackerProjectStrategy do

  let(:requester) { double(:http_requester) }
  subject { TrackerProjectStrategy.new(requester) }

  describe '#create_workload' do
    it 'should return a workload with feed and build status jobs' do
      workload = subject.create_workload(build(:project_with_tracker_integration))

      expect(workload.unfinished_job_descriptions).to eq({
                                                             project: 'https://www.pivotaltracker.com/services/v3/projects/123',
                                                             current_iteration: 'https://www.pivotaltracker.com/services/v3/projects/123/iterations/current',
                                                             iterations: 'https://www.pivotaltracker.com/services/v3/projects/123/iterations/done?offset=-10'
                                                         })
    end
  end

  describe '#fetch_status' do
    it 'makes a request with the tracker token' do
      project = build(:project_with_tracker_integration)
      url = project.tracker_project_url

      expect(requester).to receive(:initiate_request).with(url, {:head => {
          'X-TrackerToken' => 'tracker-token'
      }})

      subject.fetch_status(project, url)
    end
  end
end