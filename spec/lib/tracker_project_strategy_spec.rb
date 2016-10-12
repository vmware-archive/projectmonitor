require 'spec_helper'

describe TrackerProjectStrategy do
  let(:request_double) { double(:request) }
  let(:client_double) { double(:client, response: 'some response', error: 'some error') }
  let(:requester) { double(:http_requester, initiate_request: request_double) }
  let(:project) { build(:project_with_tracker_integration) }


  let(:requester) { double(:http_requester, initiate_request: request_double) }
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
    let(:project) { build(:project_with_tracker_integration) }
    let(:url) { project.tracker_project_url }

    before do
      allow(request_double).to receive(:callback).and_return(client_double)
      allow(request_double).to receive(:errback).and_return(client_double)
    end

    it 'makes a request with the tracker token' do
      expect(requester).to receive(:initiate_request).with(url, {:head => {
          'X-TrackerToken' => 'tracker-token'
      }})

      subject.fetch_status(project, url)
    end

    it 'yields a success message when the request is made successfully' do
      expect(request_double).to receive(:callback).and_yield(client_double)
      flag = false

      subject.fetch_status(project, url) do |_flag, response|
        flag = _flag
      end

      expect(flag).to eq(PollState::SUCCEEDED)
    end

    it 'yields an error message when the request is made unsuccessfully' do
      expect(request_double).to receive(:errback).and_yield(client_double)
      flag = false

      subject.fetch_status(project, url) do |_flag, response|
        flag = _flag
      end

      expect(flag).to eq(PollState::FAILED)
    end
  end
end