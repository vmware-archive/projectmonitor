require 'spec_helper'

describe CIPollingStrategy do
  let(:request_double) { double(:request) }
  let(:client_double) { double(:client, response: 'some response', error: 'some error') }
  let(:requester) { double(:http_requester, initiate_request: request_double) }
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
      allow(request_double).to receive(:callback).and_return(client_double)
      allow(request_double).to receive(:errback).and_return(client_double)
    end

    it 'should initiate a request to the build URL' do
      expect(requester).to receive(:initiate_request).with(url, {}).and_return(request_double)

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