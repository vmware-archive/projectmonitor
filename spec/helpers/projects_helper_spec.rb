require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject'],
                 ['Jenkins Project', 'JenkinsProject'],
                 ['Team City Project', 'TeamCityRestProject'],
                 ['Team City Project with Dependencies', 'TeamCityChainedProject'],
                 ['Legacy Team City (<= v6) Project', 'TeamCityProject'],
                 ['Travis Project', 'TravisProject']]
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

      it "should display a message and generate a guid" do
        project.should_receive :generate_guid
        project.should_receive :save!
        subject.should == "not yet configured"
      end
    end
  end
end
