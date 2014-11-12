require 'spec_helper'
require Rails.root.join('spec', 'shared', 'json_payload_examples')

describe TeamCityJsonPayload do

  let(:fixture_file)      { "success.json" }
  let(:fixture_content)   { load_fixture('teamcity_json_examples', fixture_file) }
  let(:payload)           { TeamCityJsonPayload.new.tap { |p| p.remote_addr = "localhost" } }
  let(:converted_content) { payload.convert_content!(fixture_content).first }

  it_behaves_like "a JSON payload"

  describe '#building?' do
    # success.json & building.json covered in shared examples

    before(:each) { payload.build_status_content = fixture_content }
    subject { payload }

    context 'should not be building when build result is not "running"' do
      let(:fixture_file) { 'building_not_running.json'}
      it { is_expected.to_not be_building }
    end

    context 'should not be building when notify type is not "started"' do
      let(:fixture_file) { 'building_not_started.json'}
      it { is_expected.to_not be_building }
    end
  end

  describe '#parse_build_id' do
    subject { payload.parse_build_id(converted_content) }
    it { is_expected.to eq('1') }
  end

  describe '#parse_url' do
    context 'using the old success format' do
      it 'parses the response and builds a url' do
        return_value = payload.parse_url(converted_content)
        expect(payload.parsed_url).to eql("http://localhost:8111/viewType.html?buildTypeId=bt2")
        expect(return_value).to eql("http://localhost:8111/viewLog.html?buildId=1&tab=buildResultsDiv&buildTypeId=bt2")
      end
    end

    context 'using the newer success format' do
      let(:fixture_file) { "success_alternate.json" }

      it 'parses the response for a buildStatusUrl attribute' do
        payload.parse_url(converted_content)
        expect(payload.parsed_url).to eql("http://localhost:8111/viewLog.html?buildTypeId=Foo_Bar&buildId=7")
      end
    end
  end

  describe '#parse_published_at' do
    subject { payload.parse_published_at(converted_content) }
    it { is_expected.to be_an_instance_of(Time) }
  end
end
