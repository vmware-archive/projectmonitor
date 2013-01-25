require 'spec_helper'

describe 'UrlRetriever' do
  describe '#get' do
    let(:get_request) { stub('Net::HTTP::Get', basic_auth: true) }
    let(:http_session) { stub('Net::HTTP') }
    let(:response) { stub('HTTPResponse') }
    let(:retriever) { UrlRetriever.new url }
    let(:url) { 'http://host:1010/path?a=b' }

    before do
      Net::HTTP::Get.stub(:new).with('/path?a=b').and_return(get_request)
      retriever.stub(:http).and_return(http_session)
      http_session.stub(:request).with(get_request).and_return(response)
    end

    context 'when not given a block' do
      before { get_request.should_not_receive(:basic_auth) }

      subject { retriever.get }

      it { should == response }
    end

    context 'when given a block' do
      before { get_request.should_receive(:basic_auth) }

      subject do
        retriever.get { |get_request| get_request.basic_auth }
      end

      it { should == response }
    end

    context 'when a connection refused error is raised' do
      specify do
        lambda {
          retriever.get { raise Errno::ECONNREFUSED }
        }.should raise_error(Net::HTTPError)
      end
    end
  end

  describe '#http' do
    context 'when the URI uses http' do
      let(:retriever) { UrlRetriever.new url }
      let(:url) { 'http://host:1010/path' }

      subject { retriever.http }

      its(:address) { should == 'host' }
      its(:open_timeout) { should == 30 }
      its(:port) { should == 1010 }
      its(:read_timeout) { should == 30 }
      its(:use_ssl?) { should == false }
      it { should respond_to :start }
    end

    context 'when the URI uses https' do
      let(:certificate_bundle_filename) { 'ca.crt' }
      let(:retriever) { UrlRetriever.new url }
      let(:url) { 'https://host:1010/path' }

      before { ConfigHelper.stub(:get).with(:certificate_bundle).and_return(certificate_bundle_filename) }

      subject { retriever.http }

      its(:address) { should == 'host' }
      its(:ca_file) { should == Rails.root.join(certificate_bundle_filename) }
      its(:open_timeout) { should == 30 }
      its(:port) { should == 1010 }
      its(:read_timeout) { should == 30 }
      its(:use_ssl?) { should == true }
      it { should respond_to :start }

      context 'and verify_ssl is true' do
        let(:retriever) { UrlRetriever.new url, nil, nil, true }

        subject { retriever.http }

        its(:verify_mode) { should == OpenSSL::SSL::VERIFY_PEER }
      end

      context 'and verify_ssl is false' do
        let(:retriever) { UrlRetriever.new url, nil, nil, false }

        subject { retriever.http }

        its(:verify_mode) { should == OpenSSL::SSL::VERIFY_NONE }
      end
    end
  end

  describe '#retrieve_content' do
    let(:get_request) { stub('HTTP::Get') }
    let(:http_session) { stub('Net::HTTP', request: response) }
    let(:password) { stub('password') }
    let(:url) { 'http://host/path.html?parameter=value' }
    let(:username) { stub('username') }

    before do
      Net::HTTP::Get.stub(:new).with('/path.html?parameter=value').and_return(get_request)
      retriever.stub(:http).and_return(http_session)
    end

    context 'when a username and password are supplied' do
      let(:response) { stub('HTTPResponse') }
      let(:retriever) { UrlRetriever.new(url, username, password, verify_ssl) }
      let(:verify_ssl) { stub('verify_ssl') }

      before do
        retriever.stub(:process_response).and_return('response body')
        get_request.should_receive(:basic_auth).with(username, password)
      end

      subject { retriever.retrieve_content }

      it { should == 'response body' }
    end

    context 'when a username and password are not supplied' do
      let(:response) { stub('HTTPResponse') }
      let(:retriever) { UrlRetriever.new(url) }

      before do
        retriever.stub(:process_response).and_return('response body')
        get_request.should_not_receive(:basic_auth)
      end

      subject { retriever.retrieve_content }

      it { should == 'response body' }
    end

    context 'when the response status code is in the 200s' do
      let(:response) { stub('HTTPResponse', body: 'response body', code: (rand 200..299).to_s) }
      let(:retriever) { UrlRetriever.new(url) }

      subject { retriever.retrieve_content }

      it { should == 'response body' }
    end

    #context 'when the response status code is in the 300s' do
    #  let(:response) { stub('HTTPResponse', body: 'response body', code: (rand 200..299).to_s) }
    #  let(:retriever) { UrlRetriever.new(url) }
    #
    #  subject { retriever.retrieve_content }
    #
    #  it { should == 'response body' }
    #end

    context 'when the response status code is in the 400s to 500s' do
      let(:response) { stub('HTTPResponse', body: 'response body', code: (rand 400..599).to_s) }
      let(:retriever) { UrlRetriever.new(url) }

      specify do
        lambda { retriever.retrieve_content }.should raise_error(Net::HTTPError)
      end
    end
  end

  describe '#uri' do
    context 'when no protocol is specified' do
      let(:retriever) { UrlRetriever.new 'host:1010/path?a=b' }

      subject { retriever.uri }

      its(:host) { should == 'host' }
      its(:path) { should == '/path' }
      its(:port) { should == 1010 }
      its(:query) { should == 'a=b' }
      its(:scheme) { should == 'http' }
    end

    context 'when a protocol is specified' do
      let(:retriever) { UrlRetriever.new 'gopher://host:1010/path?a=b' }

      subject { retriever.uri }

      its(:host) { should == 'host' }
      its(:path) { should == '/path' }
      its(:port) { should == 1010 }
      its(:query) { should == 'a=b' }
      its(:scheme) { should == 'gopher' }
    end
  end
end
