require 'spec_helper'

describe 'UrlRetriever' do
  describe '#retrieve_content_at' do
    let(:get_request) { stub('HTTP::Get') }
    let(:http_session) { stub('Net::HTTP', request: response) }
    let(:password) { stub('password') }
    let(:response) { stub('HTTPResponse') }
    let(:username) { stub('username') }
    let(:url) { 'http://host/path.html?parameter=value' }
    let(:verify_ssl) { stub('verify_ssl') }

    before do
      Net::HTTP::Get.stub(:new).with('/path.html?parameter=value').and_return(get_request)
      UrlRetriever.stub(:http).and_return(http_session)
      UrlRetriever.stub(:process_response).with(response, url).and_return('response body')

      get_request.should_receive(:basic_auth).with(username, password)
    end

    subject { UrlRetriever.retrieve_content_at(url, username, password, verify_ssl) }

    it { should == 'response body' }

  end

  describe '#retrieve_public_content_at' do
    let(:response) { stub('HTTPResponse') }
    let(:url) { 'http://host/path.html?parameter=value' }

    before do
      UrlRetriever.stub(:get).with(url, true).and_return(response)
      UrlRetriever.stub(:process_response).with(response, url).and_return('response body')
    end

    subject { UrlRetriever.retrieve_public_content_at url }

    it { should == 'response body' }
  end

  describe '#process_response' do
    context 'when the status code is in the 200s' do
      let(:response) { stub('HTTPResponse', body: 'response body', code: (rand 200..299).to_s) }

      subject { UrlRetriever.process_response response, 'url' }

      it { should == 'response body' }
    end

    context 'when the status code is in the 400s to 500s' do
      let(:response) { stub('HTTPResponse', body: 'response body', code: (rand 400..599).to_s) }

      specify do
        lambda { UrlRetriever.process_response response, 'url' }.should raise_error(Net::HTTPError)
      end
    end
  end

  describe '#parse_uri' do
    context 'when no protocol is specified' do
      subject { UrlRetriever.parse_uri 'host:1010/path?a=b' }

      its(:host) { should == 'host' }
      its(:path) { should == '/path' }
      its(:port) { should == 1010 }
      its(:query) { should == 'a=b' }
      its(:scheme) { should == 'http' }
    end

    context 'when a protocol is specified' do
      subject { UrlRetriever.parse_uri 'gopher://host:1010/path?a=b' }

      its(:host) { should == 'host' }
      its(:path) { should == '/path' }
      its(:port) { should == 1010 }
      its(:query) { should == 'a=b' }
      its(:scheme) { should == 'gopher' }
    end
  end

  describe '#http' do
    context 'when the URI uses http' do
      let(:uri) { URI.parse 'http://host:1010/path' }

      subject { UrlRetriever.http uri, 'whatever' }

      its(:address) { should == 'host' }
      its(:open_timeout) { should == 30 }
      its(:port) { should == 1010 }
      its(:read_timeout) { should == 30 }
      its(:use_ssl?) { should == false }
      it { should respond_to :start }
    end

    context 'when the URI uses https' do
      let(:uri) { URI.parse 'https://host:1010/path' }
      let(:certificate_bundle_filename) { 'ca.crt' }

      before { ConfigHelper.stub(:get).with(:certificate_bundle).and_return(certificate_bundle_filename) }

      subject { UrlRetriever.http uri, 'whatever' }

      its(:address) { should == 'host' }
      its(:ca_file) { should == Rails.root.join(certificate_bundle_filename) }
      its(:open_timeout) { should == 30 }
      its(:port) { should == 1010 }
      its(:read_timeout) { should == 30 }
      its(:use_ssl?) { should == true }
      it { should respond_to :start }

      context 'and verify_ssl is true' do
        subject { UrlRetriever.http uri, true }

        its(:verify_mode) { should == OpenSSL::SSL::VERIFY_PEER }
      end

      context 'and verify_ssl is false' do
        subject { UrlRetriever.http uri, false }

        its(:verify_mode) { should == OpenSSL::SSL::VERIFY_NONE }
      end
    end
  end

  describe '#get' do
    let(:get_request) { stub('Net::HTTP::Get', basic_auth: true) }
    let(:http_session) { stub('Net::HTTP') }
    let(:response) { stub('HTTPResponse') }
    let(:uri) { stub('URI', path: 'path', query: 'a=b') }
    let(:url) { 'http://host:1010/path?a=b' }

    before do
      UrlRetriever.stub(:parse_uri).with(url).and_return(uri)
      Net::HTTP::Get.stub(:new).with('path?a=b').and_return(get_request)
      UrlRetriever.stub(:http).with(uri, false).and_return(http_session)
      http_session.stub(:request).with(get_request).and_return(response)
    end

    context 'when not given a block' do
      before { get_request.should_not_receive(:basic_auth) }

      subject { UrlRetriever.get url, false }

      it { should == response }
    end

    context 'when given a block' do
      before { get_request.should_receive(:basic_auth) }

      subject do
        UrlRetriever.get url, false do |get_request|
          get_request.basic_auth
        end
      end

      it { should == response }
    end

    context 'when a connection refused error is raised' do
      specify do
        lambda {
          UrlRetriever.get(url, false) { raise Errno::ECONNREFUSED }
        }.should raise_error(Net::HTTPError)
      end
    end
  end
end

