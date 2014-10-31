require 'spec_helper'

describe TravisProject, :type => :model do

  it { is_expected.to validate_presence_of(:travis_github_account) }
  it { is_expected.to validate_presence_of(:travis_repository) }

  subject { build(:travis_project) }

  describe 'validations' do
    context "when webhooks are enabled" do
      subject { TravisProject.new(webhooks_enabled: true)}
      it { is_expected.not_to validate_presence_of(:travis_github_account) }
      it { is_expected.not_to validate_presence_of(:travis_repository) }
    end

    context "when webhooks are not enabled" do
      it { is_expected.to validate_presence_of :travis_github_account }
      it { is_expected.to validate_presence_of :travis_repository }
    end
  end

  describe '#feed_url' do
    subject { super().feed_url }
    it { is_expected.to eq('https://api.travis-ci.org/repositories/account/project/builds.json') }
  end

  describe '#project_name' do
    subject { super().project_name }
    it { is_expected.to eq('account') }
  end

  describe '#build_status_url' do
    subject { super().build_status_url }
    it { is_expected.to eq('https://api.travis-ci.org/repositories/account/project/builds.json') }
  end

  describe "#has_status?" do
    subject { project.has_status?(status) }

    let(:project) { create(:travis_project) }

    context "when the project has the status" do
      let!(:status) { project.statuses.create!(build_id: 99) }
      it { is_expected.to be true }

      context "but the given status has different result" do
        let(:status) { project.statuses.new(build_id: 99, success: true) }

        before { project.statuses.create!(build_id: 99, success: false) }

        it { is_expected.to be false }
      end
    end

    context "when the project does not have the status" do
      let!(:status) { ProjectStatus.create!(build_id: 99) }
      it { is_expected.to be false }
    end
  end
end
