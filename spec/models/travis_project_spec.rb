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
      subject { Project.new(webhooks_enabled: true)}
      it { should_not validate_presence_of(:travis_github_account) }
      it { should_not validate_presence_of(:travis_repository) }
    end

    context "when webhooks are not enabled" do
      it { should validate_presence_of :travis_github_account }
      it { should validate_presence_of :travis_repository }
    end
  end

  its(:feed_url) { should == 'http://travis-ci.org/account/project/builds.json' }
  its(:project_name) { should == 'account' }
  its(:build_status_url) { should == 'http://travis-ci.org/account/project/builds.json' }

  describe '#current_build_url' do
    let(:project) { FactoryGirl.build(:travis_project) }
    subject { project.current_build_url }

    it { should == 'http://travis-ci.org/account/project' }
  end

end
