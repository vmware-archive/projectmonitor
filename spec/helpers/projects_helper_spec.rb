require 'spec_helper'

describe ProjectsHelper, :type => :helper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      is_expected.to eq([['', ''],
                 ['Cruise Control Project', 'CruiseControlProject'],
                 ['Jenkins Project', 'JenkinsProject'],
                 ['Semaphore Project', 'SemaphoreProject'],
                 ['Team City Project', 'TeamCityRestProject'],
                 ['Team City Project (version <= 6)', 'TeamCityProject'],
                 ['Travis Project', 'TravisProject'],
                 ['Travis Pro Project', 'TravisProProject'],
                 ['Tddium Project', 'TddiumProject'],
                 ['CircleCi Project', 'CircleCiProject'],
                 ['Concourse Project', 'ConcourseProject']])
    end
  end

  describe "#project_webhooks_url" do
    subject { helper.project_webhooks_url(project) }

    context "when the project has a guid" do
      let(:project) { FactoryGirl.build(:project) }
      before { project.save }
      it { is_expected.to include project.guid }
    end

    context "when the project lacks a guid" do
      let!(:project) { FactoryGirl.create(:project) }
      before { project.tap {|p| p.guid = nil}.save! }

      it "should generate a guid" do
        expect(project).to receive :generate_guid
        expect(project).to receive :save!
        expect(subject).to eq("")
      end
    end
  end

  describe '#project_last_status_text' do
    subject { helper.project_last_status_text(project) }

    context "when the project have a payload" do
      let(:payload) { PayloadLogEntry.new(status: "status") }
      let(:project) { FactoryGirl.create(:project, payload_log_entries: [payload]) }

      context "when the project is enabled" do
        it { is_expected.to eq('Status') }

        context "but the project's latest payload doesn't have status" do
          let(:payload) { PayloadLogEntry.new(status: nil) }
          it { is_expected.to eq('Unknown Status') }
        end
      end
      context "when the project is disabled" do
        let(:project) { FactoryGirl.create(:project, enabled: false, payload_log_entries: [payload]) }
        it { is_expected.to eq('Disabled') }
      end
    end

    context "when the project doesn't have payloads" do
      let(:project) { FactoryGirl.create(:project) }
      it { is_expected.to eq('None') }
    end
  end

  describe "#project_last_status" do
    let(:project) { double(:project) }
    let(:enabled) { nil }


    context "when there is payload log entries" do
      let(:status) { double(:status) }

      before do
        allow(project).to receive(:enabled?).and_return(enabled)
        allow(project).to receive_message_chain(:payload_log_entries, :latest, :status).and_return([status])
      end

      context "when the project is enabled" do
        let(:enabled) { true }

        it "should return a link to the latest status" do
          expect(helper.project_last_status(project)).to have_selector("a")
          expect(helper.project_last_status(project)).not_to include("Disabled")
        end
      end

      context "when the project is disabled" do
        let(:enabled) { false }

        it "should return a paragraph selector with diabled as the text" do
          expect(helper.project_last_status(project)).to have_selector("p")
          expect(helper.project_last_status(project)).to include("Disabled")
        end
      end
    end

    context "when there are no payload log entries" do
      before do
        allow(project).to receive_message_chain(:payload_log_entries, :latest).and_return(nil)
      end

      it "should return the text None" do
        expect(helper.project_last_status(project)).to eq("None")
      end
    end
  end
end
