require 'spec_helper'

describe CIPollingStrategy do
  let(:request) { double(:request) }
  let(:client_response_header) { double(:client_response_header, status: 200) }
  let(:client) { double(:client, response: 'some response', error: 'some error', response_header: client_response_header) }
  let(:requester) { double(:http_requester, initiate_request: request) }
  let(:project) { build(:jenkins_project) }

  subject { CIPollingStrategy.new(requester) }

  describe '#create_workload' do
    it 'should return a workload with feed and build status jobs' do
      workload = subject.create_workload(build(:jenkins_project))

      expect(workload.unfinished_job_descriptions).to eq({
                                                             feed_url: 'http://www.example.com/job/project/rssAll',
                                                             build_status_url: 'http://www.example.com/cc.xml',
                                                         })
    end
  end

  describe '#fetch_status' do
    let(:url) { project.feed_url }

    before do
      allow(request).to receive(:callback).and_return(client)
      allow(request).to receive(:errback).and_return(client)
    end

    it 'should initiate a request to the build URL' do
      expect(requester).to receive(:initiate_request).with(url, {}).and_return(request)

      subject.fetch_status(project, url)
    end

    it 'should pass along auth username and password, when present' do
      project.auth_username = 'user'
      project.auth_password = 'password'

      expect(requester).to receive(:initiate_request).with(url, {:head => {'authorization' => ['user', 'password']}})

      subject.fetch_status(project, url)
    end

    it 'should pass along the option to accept mime types, when present' do
      project = build(:circle_ci_project)
      project.auth_username = 'user'
      project.auth_password = 'password'

      expect(requester).to receive(:initiate_request).with(url, {:head => {
          'Accept' => 'application/json',
          'authorization' => ['user', 'password']
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