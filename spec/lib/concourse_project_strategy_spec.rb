require 'spec_helper'

describe ConcourseProjectStrategy do
  let(:request_double) { double(:request) }
  let(:client_double) { double(:client, response: 'some response', error: 'some error') }
  let(:requester) { double(:http_requester, initiate_request: request_double) }
  let(:project) { build(:concourse_project,
                        ci_base_url: 'http://concourse.com',
                        auth_username: 'me',
                        auth_password: 'pw')
  }
  let(:concourse_authenticator) { double(:concourse_authenticator) }

  subject { ConcourseProjectStrategy.new(requester, concourse_authenticator) }

  describe '#fetch_status' do
    let(:url) { project.feed_url }

    before do
      allow(request_double).to receive(:callback).and_return(client_double)
      allow(request_double).to receive(:errback).and_return(client_double)
      allow(concourse_authenticator).to receive(:authenticate).with(project.auth_url, project.auth_username, project.auth_password).and_yield('session-token')
    end

    it 'makes a request to the auth endpoint, then makes a request for the build status' do
      expect(requester).to receive(:initiate_request).with(url, {head: {'Cookie' => 'ATC-Authorization=Bearer session-token'}}).and_return(request_double)

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