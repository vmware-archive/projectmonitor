require 'spec_helper'

describe CruiseControlXmlPayload do
  let(:project) { create(:cruise_control_project, cruise_control_rss_feed_url: "http://foo.bar.com:3434/projects/Socialitis.rss") }
  let(:payload_processor) { PayloadProcessor.new(project_status_updater: StatusUpdater.new) }

  subject do
    payload_processor.process_payload(project: project, payload: payload)
    project
  end

  describe "project status" do
    context "when not currently building" do
      let(:status_content) { CCRssExample.new(rss).read }
      let(:payload) { CruiseControlXmlPayload.new(project.name) }
      before { payload.status_content = status_content }

      context "when build was successful" do
        let(:rss) { "success.rss" }
        it { is_expected.to be_success }
      end

      context "when build had failed" do
        let(:rss) { "failure.rss" }
        it { is_expected.to be_failure }
      end
    end

    context "when building" do
      let(:payload) { CruiseControlXmlPayload.new(project.name) }

      it "remains green when existing status is green" do
        status_content = CCRssExample.new("success.rss").read
        payload.status_content = status_content
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        build_content = BuildingStatusExample.new("socialitis_building.xml").read
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_success
        expect(project.statuses).to eq(statuses)
      end

      it "remains red when existing status is red" do
        status_content = CCRssExample.new("failure.rss").read
        payload.status_content = status_content
        payload_processor.process_payload(project: project, payload: payload)
        statuses = project.statuses
        build_content = BuildingStatusExample.new("socialitis_building.xml").read
        payload.build_status_content = build_content
        payload_processor.process_payload(project: project, payload: payload)
        expect(project).to be_failure
        expect(project.statuses).to eq(statuses)
      end
    end
  end

  describe "building status" do
    let(:build_content) { BuildingStatusExample.new(xml).read }
    let(:payload) { CruiseControlXmlPayload.new('Socialitis') }
    before { payload.build_status_content = build_content }

    context "when building" do
      let(:xml) { "socialitis_building.xml" }
      it { is_expected.to be_building }
    end

    context "when not building" do
      let(:xml) { "socialitis_not_building.xml" }
      it { is_expected.not_to be_building }
    end
  end

  describe "saving data" do
    let(:example) { CCRssExample.new(xml) }
    let(:status_content) { example.read }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }

    context "successful parsing" do
      before { payload.status_content = status_content }
      describe "when build was successful" do
        let(:xml) { "success.rss" }

        describe '#latest_status' do
          subject { super().latest_status }
          it { is_expected.to be_success }
        end

        it "return the link to the checkin" do
          expect(subject.latest_status.url).to eq(CCRssExample.new("success.rss").xpath_content("/rss/channel/item/link"))
        end

        it "should return the published date of the checkin" do
          expect(subject.latest_status.published_at).to eq(Time.parse(CCRssExample.new("success.rss").xpath_content("/rss/channel/item/pubDate")))
        end
      end

      describe "when build failed" do
        let(:xml) { "failure.rss" }

        describe '#latest_status' do
          subject { super().latest_status }
          it { is_expected.not_to be_success }
        end

        it "return the link to the checkin" do
          expect(subject.latest_status.url).to eq(CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/link"))
        end

        it "should return the published date of the checkin" do
          expect(subject.latest_status.published_at).to eq(Time.parse(CCRssExample.new("failure.rss").xpath_content("/rss/channel/item/pubDate")))
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
    let(:status_content) { "<foo><bar>baz</bar></foo>" }
    let(:payload) { CruiseControlXmlPayload.new(project.name) }
    before { payload.status_content = status_content }

    it { is_expected.not_to be_building }

    it "should not create a status" do
      expect { subject }.not_to change(ProjectStatus, :count)
    end
  end
end
