require 'spec_helper'

describe 'UrlRetriever' do

  describe '#retrieve_content_at' do
    context 'simple uri' do
      let(:stubbed_response) { stub(:code => '200', :body => 'mock body') }

      before do
        Net::HTTP.stub!(:new).and_return(stub('Net::HTTP stub', :[] => nil, :code => '200', :read_timeout= => nil, :open_timeout= => nil, :start => stubbed_response).as_null_object)
        Net::HTTP::Get.should_receive(:new).with('/path.html?parameter=value').and_return(stub('HTTP::Get stub').as_null_object)
      end

      subject { UrlRetriever.retrieve_content_at('http://host/path.html?parameter=value') }

      it { should == 'mock body' }
    end

    context 'basic auth uri' do
      let(:http_get) { stub('HTTP::Get stub') }
      let(:stubbed_response) { stub(:code => '200', :body => 'mock body') }

      before do
        stubbed_response.should_receive(:[]).with('www-authenticate').and_return(nil)
        http_get.should_receive(:basic_auth).with('user', 'pass')
        Net::HTTP.stub!(:new).and_return(stub('Net::HTTP stub', :[] => nil, :code => '200', :read_timeout= => nil, :open_timeout= => nil, :start => stubbed_response).as_null_object)
        Net::HTTP::Get.should_receive(:new).with('/path.html?parameter=value').and_return(http_get)
      end

      subject { UrlRetriever.retrieve_content_at('http://host/path.html?parameter=value', 'user', 'pass') }

      it { should == 'mock body' }
    end

    context 'non-responsive server' do
      let(:net_http) { double(:net_http).as_null_object }

      before do
        Net::HTTP.stub(:new).and_return(net_http)
        net_http.should_receive(:start).and_raise(Errno::ECONNREFUSED)
      end

      subject { UrlRetriever.retrieve_content_at('http://localhost:8111/') }

      it 'raises an error' do
        expect{ subject }.to raise_error(Net::HTTPError)
      end
    end
  end

  describe '#prepend_scheme' do

    subject { UrlRetriever.prepend_scheme(url) }
    context 'when no scheme is provided' do
      let(:url) { 'example.com' }
      it { should == 'http://example.com'}
    end

    context 'when some scheme is provided' do
      let(:url) { 'gopher://example.com' }
      it { should == 'gopher://example.com'}
    end

  end

end
