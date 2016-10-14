require 'spec_helper'

describe 'UrlRetriever' do
  describe '#get' do
    let(:get_request) { double('Net::HTTP::Get', basic_auth: true) }
    let(:http_session) { double('Net::HTTP') }
    let(:response) { double('HTTPResponse') }
    let(:retriever) { UrlRetriever.new url }
    let(:url) { 'http://host:1010/path?a=b' }

    before do
      allow(Net::HTTP::Get).to receive(:new).with('/path?a=b').and_return(get_request)
      allow(retriever).to receive(:http).and_return(http_session)
      allow(http_session).to receive(:request).with(get_request).and_return(response)
    end

    context 'when not given a block' do
      before { expect(get_request).not_to receive(:basic_auth) }

      subject { retriever.get }

      it { is_expected.to eq(response) }
    end

    context 'when given a block' do
      before { expect(get_request).to receive(:basic_auth) }

      subject do
        retriever.get { |get_request| get_request.basic_auth }
      end

      it { is_expected.to eq(response) }
    end

    context 'when a connection refused error is raised' do
      specify do
        expect {
          retriever.get { raise Errno::ECONNREFUSED }
        }.to raise_error(Net::HTTPError)
      end
    end
  end

  describe '#http' do
    context 'when the URI uses http' do
      let(:retriever) { UrlRetriever.new url }
      let(:url) { 'http://host:1010/path' }

      subject { retriever.http }

      describe '#address' do
        subject { super().address }
        it { is_expected.to eq('host') }
      end

      describe '#open_timeout' do
        subject { super().open_timeout }
        it { is_expected.to eq(30) }
      end

      describe '#port' do
        subject { super().port }
        it { is_expected.to eq(1010) }
      end

      describe '#read_timeout' do
        subject { super().read_timeout }
        it { is_expected.to eq(30) }
      end

      describe '#use_ssl?' do
        subject { super().use_ssl? }
        it { is_expected.to eq(false) }
      end
      it { is_expected.to respond_to :start }
    end

    context 'when the URI uses https' do
      let(:certificate_bundle_filename) { 'ca.crt' }
      let(:retriever) { UrlRetriever.new url }
      let(:url) { 'https://host:1010/path' }

      before { allow(ConfigHelper).to receive(:get).with(:certificate_bundle).and_return(certificate_bundle_filename) }

      subject { retriever.http }

      describe '#address' do
        subject { super().address }
        it { is_expected.to eq('host') }
      end

      describe '#ca_file' do
        subject { super().ca_file }
        it { is_expected.to eq(Rails.root.join(certificate_bundle_filename).to_s) }
      end

      describe '#open_timeout' do
        subject { super().open_timeout }
        it { is_expected.to eq(30) }
      end

      describe '#port' do
        subject { super().port }
        it { is_expected.to eq(1010) }
      end

      describe '#read_timeout' do
        subject { super().read_timeout }
        it { is_expected.to eq(30) }
      end

      describe '#use_ssl?' do
        subject { super().use_ssl? }
        it { is_expected.to eq(true) }
      end
      it { is_expected.to respond_to :start }
    end
  end

  describe '#retrieve_content' do
    let(:get_request) { double('HTTP::Get') }
    let(:http_session) { double('Net::HTTP', request: response) }
    let(:password) { double('password') }
    let(:url) { 'http://host/path.html?parameter=value' }
    let(:username) { double('username') }

    before do
      allow(Net::HTTP::Get).to receive(:new).with('/path.html?parameter=value').and_return(get_request)
      allow(retriever).to receive(:http).and_return(http_session)
    end

    context 'when a username and password are supplied' do
      let(:response) { double('HTTPResponse') }
      let(:retriever) { UrlRetriever.new(url, username, password) }

      before do
        allow(retriever).to receive(:process_response).and_return('response body')
        expect(get_request).to receive(:basic_auth).with(username, password)
      end

      subject { retriever.retrieve_content }

      it { is_expected.to eq('response body') }
    end

    context 'when a username and password are not supplied' do
      let(:response) { double('HTTPResponse') }
      let(:retriever) { UrlRetriever.new(url) }

      before do
        allow(retriever).to receive(:process_response).and_return('response body')
        expect(get_request).not_to receive(:basic_auth)
      end

      subject { retriever.retrieve_content }

      it { is_expected.to eq('response body') }
    end

    context 'when the response status code is in the 200s' do
      let(:response) { double('HTTPResponse', body: 'response body', code: (rand 200..299).to_s) }
      let(:retriever) { UrlRetriever.new(url) }

      subject { retriever.retrieve_content }

      it { is_expected.to eq('response body') }
    end

    context 'when the response status code is in the 300s' do
      before do
        expect(UrlRetriever).to receive(:new).
            with(new_location, nil, nil).
            and_return(double(:url_ret, retrieve_content: "hello, is it me you're looking for?"))
      end

      let(:new_location) { 'http://placekitten.com/500/500' }
      let(:response) { double('HTTPResponse', body: nil, header: {'location' => new_location}, code: (rand 300..399).to_s) }
      let(:retriever) { UrlRetriever.new(url) }

      subject { retriever.retrieve_content }

      it { is_expected.to eq("hello, is it me you're looking for?") }
    end

    context 'when the response status code is in the 400s to 500s' do
      let(:response) { double('HTTPResponse', body: 'response body', code: (rand 400..599).to_s) }
      let(:retriever) { UrlRetriever.new(url) }

      specify do
        expect { retriever.retrieve_content }.to raise_error(Net::HTTPError)
      end
    end
  end

  describe '#uri' do
    context 'when no protocol is specified' do
      let(:retriever) { UrlRetriever.new 'host:1010/path?a=b' }

      subject { retriever.uri }

      describe '#host' do
        subject { super().host }
        it { is_expected.to eq('host') }
      end

      describe '#path' do
        subject { super().path }
        it { is_expected.to eq('/path') }
      end

      describe '#port' do
        subject { super().port }
        it { is_expected.to eq(1010) }
      end

      describe '#query' do
        subject { super().query }
        it { is_expected.to eq('a=b') }
      end

      describe '#scheme' do
        subject { super().scheme }
        it { is_expected.to eq('http') }
      end
    end

    context 'when a protocol is specified' do
      let(:retriever) { UrlRetriever.new 'gopher://host:1010/path?a=b' }

      subject { retriever.uri }

      describe '#host' do
        subject { super().host }
        it { is_expected.to eq('host') }
      end

      describe '#path' do
        subject { super().path }
        it { is_expected.to eq('/path') }
      end

      describe '#port' do
        subject { super().port }
        it { is_expected.to eq(1010) }
      end

      describe '#query' do
        subject { super().query }
        it { is_expected.to eq('a=b') }
      end

      describe '#scheme' do
        subject { super().scheme }
        it { is_expected.to eq('gopher') }
      end
    end
  end
end
