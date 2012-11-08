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

  describe '#current_build_url' do
    subject { project.current_build_url }
    let(:project) { FactoryGirl.build(:travis_project) }

    it "returns a url to the project" do
      should == 'https://travis-ci.org/account/project'
    end
  end
end
