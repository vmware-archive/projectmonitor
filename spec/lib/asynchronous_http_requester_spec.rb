require 'spec_helper'

describe AsynchronousHttpRequester do

  subject { AsynchronousHttpRequester.new }

  let(:connection) { double(:connection) }

  before do
    allow(EM::HttpRequest).to receive(:new).and_return(connection)
    allow(connection).to receive(:get)
  end

  describe '#initiate_request' do
    it 'should make a GET request with the options merged into the header' do
      expect(connection).to receive(:get).with({redirects: 10,
                                                head: {'Accept' => 'text/html'}})

      subject.initiate_request('http://some/url', {head: {'Accept' => 'text/html'}})
    end

    it 'should specify timeouts' do
      expect(EM::HttpRequest).to receive(:new).with('http://some/url',
                                                    {connect_timeout: 60, inactivity_timeout: 30}
      )

      subject.initiate_request('http://some/url', {})
    end

    it 'should prepend http:// if the url has no protocol' do
      expect(EM::HttpRequest).to receive(:new).with('http://some/url', anything)

      subject.initiate_request('some/url', {})
    end

    describe 'when the url is invalid' do
      before do
        allow(connection).to receive(:get).and_raise(Addressable::URI::InvalidURIError)
      end

      it 'should return nil' do
        expect(subject.initiate_request('http://some/url', {})).to be_nil
      end

      it 'should log an error' do
        expect {
          subject.initiate_request('http://some/url', {})
        }.to output(/ERROR/).to_stdout
      end
    end
  end
end