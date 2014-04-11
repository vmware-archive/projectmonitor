require 'spec_helper'

describe TravisProject do

  it { should validate_presence_of(:travis_github_account) }
  it { should validate_presence_of(:travis_repository) }

  subject { FactoryGirl.build(:travis_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:travis_project) }
    it { should be_valid }
  end

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { TravisProject.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:travis_github_account) }
      it { should_not validate_presence_of(:travis_repository) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of :travis_github_account }
      it { should validate_presence_of :travis_repository }
    end
  end

  its(:feed_url) { should == 'https://api.travis-ci.org/repositories/account/project/builds.json' }
  its(:project_name) { should == 'account' }
  its(:build_status_url) { should == 'https://api.travis-ci.org/repositories/account/project/builds.json' }

  describe "#has_status?" do
    subject { project.has_status?(status) }

    let(:project) { FactoryGirl.create(:travis_project) }

    context "when the project has the status" do
      let!(:status) { project.statuses.create!(build_id: 99) }
      it { should be_true }

      context "but the given status has different result" do
        let(:status) { project.statuses.new(build_id: 99, success: true) }

        before { project.statuses.create!(build_id: 99, success: false) }

        it { should be_false }
      end
    end

    context "when the project does not have the status" do
      let!(:status) { ProjectStatus.create!(build_id: 99) }
      it { should be_false }
    end
  end
end
