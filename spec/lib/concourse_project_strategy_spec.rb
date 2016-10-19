require 'spec_helper'

describe ConcourseProjectStrategy do
  let(:request) { double(:request) }
  let(:response_header) { double(:response_header, status: 200) }
  let(:client) { double(:client, response: 'some response', error: 'some error', response_header: response_header) }
  let(:requester) { double(:asynchronous_http_requester, initiate_request: request) }
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
      allow(request).to receive(:callback)
      allow(request).to receive(:errback)
      allow(concourse_authenticator).to receive(:authenticate).
          with(project.auth_url, project.auth_username, project.auth_password).
          and_yield(PollState::SUCCEEDED, 200, 'session-token')
    end

    context 'when the auth request succeeds' do
      it 'makes a request to the auth endpoint, then makes a request for the build status' do
        expect(requester).to receive(:initiate_request).with(url, {head: {'Cookie' => 'ATC-Authorization=Bearer session-token'}}).and_return(request)

        subject.fetch_status(project, url)
      end

      it 'yields a success message when the request is made successfully' do
        expect(request).to receive(:callback).and_yield(client)
        flag = false

        subject.fetch_status(project, url) do |_flag, response|
          flag = _flag
        end

        expect(flag).to eq(PollState::SUCCEEDED)
      end

      it 'yields an error message when the request fails to connect to the concourse server' do
        expect(request).to receive(:errback).and_yield(client)
        flag = false

        subject.fetch_status(project, url) do |_flag, response|
          flag = _flag
        end

        expect(flag).to eq(PollState::FAILED)
      end
    end

    context 'when the auth request fails' do
      before do
        allow(concourse_authenticator).to receive(:authenticate).
            with(project.auth_url, project.auth_username, project.auth_password).
            and_yield(PollState::FAILED, 401, 'authorization failed')
      end

      it 'should yield a failure with the auth failure message' do
        block_called = false

        subject.fetch_status(project, url) do |poll_state, response, status_code|
          expect(poll_state).to eq(PollState::FAILED)
          expect(response).to eq('authorization failed')
          expect(status_code).to eq(401)
          block_called = true
        end

        expect(block_called).to eq(true)
      end
    end
  end
end