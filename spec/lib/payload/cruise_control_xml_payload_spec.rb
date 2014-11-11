require 'spec_helper'

describe CruiseControlXmlPayload do
  let(:fixture_dir) { "cc_rss_examples" }
  let(:content) { load_fixture(fixture_dir, fixture_file) }
  let(:project) { create(:cruise_control_project, cruise_control_rss_feed_url: "http://foo.bar.com:3434/projects/Socialitis.rss") }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }

  subject do
    payload_processor.process_payload(project: project, payload: payload)
    project
  end

  describe "project status" do
    context "when not currently building" do
      let(:payload) { CruiseControlXmlPayload.new(project.name) }
      before { payload.status_content = content }

      context "when build was successful" do
        let(:fixture_file) { "success.rss" }
        it { is_expected.to be_success }
      end

      context "when build had failed" do
        let(:fixture_file) { "failure.rss" }
        it { is_expected.to be_failure }
      end
    end

    context "when building" do
      let(:payload) { CruiseControlXmlPayload.new(project.name) }
      let(:build_content) { load_fixture(fixture_dir, 'socialitis_building.xml') }

      it "remains green when existing status is green" do
        payload.status_content = load_fixture(fixture_dir, "success.rss")
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_success
        expect(project.statuses).to eq(statuses)
      end

      it "remains red when existing status is red" do
        payload.status_content = load_fixture(fixture_dir, "failure.rss")
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_failure
        expect(project.statuses).to eq(statuses)
      end
    end
  end

  describe "building status" do
    let(:build_content) { load_fixture(fixture_dir, build_fixture_file) }
    let(:payload) { CruiseControlXmlPayload.new('Socialitis') }
    before { payload.build_status_content = build_content }

    context "when building" do
      let(:build_fixture_file) { "socialitis_building.xml" }
      it { is_expected.to be_building }
    end

    context "when not building" do
      let(:build_fixture_file) { "socialitis_not_building.xml" }
      it { is_expected.not_to be_building }
    end
  end

  describe "saving data" do
    let(:example) { Nokogiri::XML(content) }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }

    context "successful parsing" do
      before { payload.status_content = content }
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

    context "bad XML data" do
      let(:wrong_status_content) { "some non xml content" }
      describe "#status_content" do
        it "should log errors" do
          expect(payload).to receive("log_error")
          payload.status_content = wrong_status_content
        end
      end
      describe "#build_status_content" do
        it "should log errors" do
          expect(payload).to receive("log_error")
          payload.build_status_content = wrong_status_content
        end
      end
    end
  end

  describe "with invalid xml" do
    let(:invalid_xml) { "<foo><bar>baz</bar></foo>" }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }
    before { payload.status_content = invalid_xml }

    it { is_expected.not_to be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
