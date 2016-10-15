require 'spec_helper'

describe NetHttpBuilder do
  describe '#build' do
    it 'should build a Net::HTTP object with the specified uri' do
      http = NetHttpBuilder.new.build(URI.parse('https://host/url'))

      expect(http.address).to eq('host')
      expect(http.use_ssl?).to eq(true)
      expect(http.ca_file).to include('/ca-certificates.crt')
    end

    it 'should build a Net::HTTP object without SSL' do
      http = NetHttpBuilder.new.build(URI.parse('http://host/url'))
      expect(http.use_ssl?).to eq(false)
    end
  end
end