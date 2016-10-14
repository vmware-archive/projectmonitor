require 'spec_helper'

describe ConcourseAuthenticator do

  let(:requester) { double(:http_requester, initiate_request: request) }
  let(:request) { double(:request) }
  let(:response_header) { double(:response_header, status: 200) }
  let(:client) { double(:client, response: '{"some": "json"}', error: 'some error', response_header: response_header) }
  subject { ConcourseAuthenticator.new(requester) }

  describe '#authenticate' do
    before do
      allow(request).to receive(:callback).and_yield(client)
      allow(request).to receive(:errback)
    end

    context 'when the request succeeds' do
      it 'makes a basic auth request to concourse and yields the session token' do
        allow(client).to receive(:response).and_return({value: 'session-token'}.to_json)
        allow(requester).to receive(:initiate_request).with('https://auth/url', {:head => {'authorization' => ['user', 'pass']}}).and_return(request)

        block_called = false
        subject.authenticate('https://auth/url', 'user', 'pass') do |poll_state, status_code, session_token|
          expect(poll_state).to eq(PollState::SUCCEEDED)
          expect(status_code).to eq(200)
          expect(session_token).to eq('session-token')
          block_called = true
        end

        expect(block_called).to eq(true)
      end
    end

    context 'when the request fails due to bad credentials' do
      before do
        allow(client).to receive(:response).and_return('authorization failed')
        allow(response_header).to receive(:status).and_return(401)
      end

      it 'should yield a failure' do
        block_called = false
        subject.authenticate('url', 'uname', 'pw') do |poll_state, status_code, response|
          expect(poll_state).to eq(PollState::FAILED)
          expect(status_code).to eq(401)
          expect(response).to eq('authorization failed')
          block_called = true
        end

        expect(block_called).to eq(true)
      end
    end

    context 'when the request fails because concourse is not configured properly' do
      before do
        allow(requester).to receive(:initiate_request).and_return(nil)
      end

      it 'should log an error' do
        expect {
          subject.authenticate('https://auth/url', 'user', 'pass') {}
        }.to output(/Error/).to_stdout
      end

      it 'should yield a failure' do
        block_called = false

        subject.authenticate('url', 'uname', 'pw') do |poll_state, status_code, response|
          expect(poll_state).to eq(PollState::FAILED)
          expect(status_code).to eq(-1)
          expect(response).to eq('failed')
          block_called = true
        end

        expect(block_called).to eq(true)
      end
    end

    context 'when the request fails because of a network error' do
      before do
        allow(request).to receive(:callback)
        allow(request).to receive(:errback).and_yield(client)
      end

      it 'yields an error message' do
        expect(request).to receive(:errback).and_yield(client)
        block_called = false

        subject.authenticate('url', 'uname', 'pw') do |poll_state, status_code, response|
          expect(poll_state).to eq(PollState::FAILED)
          expect(status_code).to eq(-1)
          expect(response).to eq('network error')
          block_called = true
        end

        expect(block_called).to eq(true)
      end
    end
  end
end