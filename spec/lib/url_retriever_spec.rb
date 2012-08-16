require 'spec_helper'

describe UrlRetriever do

  let(:http_client) { double }
  let(:url) { 'http://host/path.html?parameter=value' }
  let(:body) { double }

  before do
    HTTPClient.stub(:new).and_return(http_client)
    http_client.stub(:get).and_return(double(:message, code: 200, body: body))
  end

  describe '#retrieve_content_at' do
    subject { UrlRetriever.retrieve_content_at(url) }

    context 'when no user credentials have been provided' do
      it 'calls get with the url' do
        http_client.should_receive(:get).with(url)
        subject
      end

      it 'returns the message body' do
        subject.should == body
      end
    end

    context 'when the server returns a failure status code' do
      before do
        http_client.stub(:get).and_return(double(:message, code: 500, body: nil))
      end

      it 'raises an HTTP exception' do
        expect do
          subject
        end.to raise_error(Net::HTTPError)
      end
    end

    context 'when user credentials have been provided' do
      subject { UrlRetriever.retrieve_content_at(url, 'user', 'pass') }

      it 'sets the authentication parameters' do
        http_client.should_receive(:set_auth).with(nil, 'user', 'pass')
        subject
      end
    end

  end
end
