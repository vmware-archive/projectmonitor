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
    it { should validate_presence_of :travis_github_account }
    it { should validate_presence_of :travis_repository }
  end

  its(:feed_url) { should == 'http://travis-ci.org/account/project/builds.json' }
  its(:project_name) { should == 'account' }
  its(:build_status_url) { should == 'http://travis-ci.org/account/project/builds.json' }

end
