require 'spec_helper'

describe ConcourseAuthenticator do

  let(:requester) { double(:http_requester, initiate_request: request) }
  let(:request) { double(:request) }
  let(:client) { double(:client, response: '{"some": "json"}', error: 'some error') }
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

        token = '<not set>'
        subject.authenticate('https://auth/url', 'user', 'pass') do |session_token|
          token = session_token
        end

        expect(token).to eq('session-token')
      end
    end

    context 'when the request fails because concourse is not configured properly' do
      before do
        allow(requester).to receive(:initiate_request).and_return(nil)
      end

      it 'should log an error' do
        expect {
          subject.authenticate('https://auth/url', 'user', 'pass')
        }.to output(/Error/).to_stdout
      end
    end

    context 'when the request fails because of a network error' do
      it 'yields an error message' do
        expect(request).to receive(:errback).and_yield(client)
        flag = false

        subject.authenticate('url', 'uname', 'pw') do |_flag, response|
          flag = _flag
        end

        expect(flag).to eq(PollState::FAILED)
      end
    end
  end
end