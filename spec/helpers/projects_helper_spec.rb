require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject'],
                 ['Jenkins Project', 'JenkinsProject'],
                 ['Semaphore Project', 'SemaphoreProject'],
                 ['Team City Project', 'TeamCityRestProject'],
                 ['Team City Project (version <= 6)', 'TeamCityProject'],
                 ['Travis Project', 'TravisProject'],
                 ['Tddium Project', 'TddiumProject']]
    end
  end

  describe "#project_webhooks_url" do
    subject { helper.project_webhooks_url(project) }

    context "when the project has a guid" do
      let(:project) { FactoryGirl.build(:project) }
      before { project.save }
      it { should include project.guid }
    end

    context "when the project lacks a guid" do
      let!(:project) { FactoryGirl.create(:project) }
      before { project.tap {|p| p.guid = nil}.save! }

      it "should generate a guid" do
        project.should_receive :generate_guid
        project.should_receive :save!
        subject.should == ""
      end
    end
  end

  describe '#project_status_link' do
    context 'the current_build_url is not blank' do
      let(:code) { double }
      let(:url) { double }
      let(:project) { double(:project, current_build_url: url, code: code)}

      it 'renders a link to the current_build_url using the link helper' do
        helper.should_receive(:link_to).with(code, url)
        helper.project_status_link(project)
      end
    end

    context 'the current_build_url is blank' do
      let(:project) { double(:project, current_build_url: '', code: 'AOG') }

      it 'returns the project code' do
        helper.project_status_link(project).should == 'AOG'
      end
    end
  end

  describe "#project_last_status" do
    let(:project) { double(:project) }
    let(:enabled) { nil }


    context "when there is payload log entries" do
      let(:status) { double(:status) }

      before do
        project.stub(:enabled?).and_return(enabled)
        project.stub_chain(:payload_log_entries, :latest, :status).and_return([status])
      end

      context "when the project is enabled" do
        let(:enabled) { true }

        it "should return a link to the latest status" do
          helper.project_last_status(project).should have_selector("a")
          helper.project_last_status(project).should_not include("Disabled")
        end
      end

      context "when the project is disabled" do
        let(:enabled) { false }

        it "should return a paragraph selector with diabled as the text" do
          helper.project_last_status(project).should have_selector("p")
          helper.project_last_status(project).should include("Disabled")
        end
      end
    end

    context "when there are no payload log entries" do
      before do
        project.stub_chain(:payload_log_entries, :latest).and_return(nil)
      end

      it "should return the text None" do
        helper.project_last_status(project).should == ("None")
      end
    end
  end
end
