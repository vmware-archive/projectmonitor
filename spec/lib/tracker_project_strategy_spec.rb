require 'spec_helper'

describe TrackerProjectStrategy do
  let(:request) { double(:request) }
  let(:client_response_header) { double(:client_response_header, status: 200) }
  let(:client) { double(:client, response: 'some response', error: 'some error', response_header: client_response_header) }
  let(:requester) { double(:http_requester, initiate_request: request) }
  let(:project) { build(:project_with_tracker_integration) }


  let(:requester) { double(:http_requester, initiate_request: request) }
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
      allow(request).to receive(:callback).and_return(client)
      allow(request).to receive(:errback).and_return(client)
    end

    it 'makes a request with the tracker token' do
      expect(requester).to receive(:initiate_request).with(url, {:head => {
          'X-TrackerToken' => 'tracker-token'
      }})

      subject.fetch_status(project, url)
    end

    it 'yields a success message when the request is made successfully' do
      expect(request).to receive(:callback).and_yield(client)
      flag = false
      status_code = nil

      subject.fetch_status(project, url) do |_flag, response, status|
        flag = _flag
        status_code = status
      end

      expect(flag).to eq(PollState::SUCCEEDED)
      expect(status_code).to eq(200)
    end

    it 'yields an error message when the request is made unsuccessfully' do
      expect(request).to receive(:errback).and_yield(client)
      flag = false
      status_code = nil

      subject.fetch_status(project, url) do |_flag, response, status|
        flag = _flag
        status_code = status
      end

      expect(flag).to eq(PollState::FAILED)
      expect(status_code).to eq(-1)
    end
  end
end