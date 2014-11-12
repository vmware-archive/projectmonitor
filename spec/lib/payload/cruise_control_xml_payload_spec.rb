require 'spec_helper'
require Rails.root.join('spec', 'shared', 'xml_payload_examples')

describe CruiseControlXmlPayload do
  let(:fixture_ext)         { "rss" }
  let(:fixture_dir)         { "cc_rss_examples" }
  let(:fixture_content)     { load_fixture(fixture_dir, fixture_file) }
  let(:build_fixture_file)  { "socialitis_building.xml" }
  let(:build_content)       { load_fixture(fixture_dir, build_fixture_file) }

  let(:project)           { create(:cruise_control_project, cruise_control_rss_feed_url: "http://foo.bar.com:3434/projects/Socialitis.rss") }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }
  let(:payload)           { CruiseControlXmlPayload.new(project.name) }

  subject do
    payload_processor.process_payload(project: project, payload: payload)
    project
  end

  it_behaves_like "a XML payload"

  describe "building status" do
    let(:payload) { CruiseControlXmlPayload.new('Socialitis') }
    before { payload.build_status_content = build_content }

    context "when building" do
      it { is_expected.to be_building }
    end

    context "when not building" do
      let(:build_fixture_file) { "socialitis_not_building.xml" }
      it { is_expected.not_to be_building }
    end
  end

  describe "saving data" do
    let(:example) { Nokogiri::XML(fixture_content) }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }

    context "successful parsing" do
      before { payload.status_content = fixture_content }
      describe "when build was successful" do
        let(:fixture_file) { "success.rss" }

        describe '#latest_status' do
          subject { super().latest_status }
          it { is_expected.to be_success }
        end

        it "return the link to the checkin" do
          expect(subject.latest_status.url).to eq(example.at_xpath("/rss/channel/item/link").content)
        end

        it "should return the published date of the checkin" do
          expect(subject.latest_status.published_at).to eq(Time.parse(example.at_xpath("/rss/channel/item/pubDate").content))
        end
      end

      describe "when build failed" do
        let(:fixture_file) { "failure.rss" }

        describe '#latest_status' do
          subject { super().latest_status }
          it { is_expected.not_to be_success }
        end

        it "return the link to the checkin" do
          expect(subject.latest_status.url).to eq(example.at_xpath("/rss/channel/item/link").content)
        end

        it "should return the published date of the checkin" do
          expect(subject.latest_status.published_at).to eq(Time.parse(example.at_xpath("/rss/channel/item/pubDate").content))
        end
      end
    end
  end
end
