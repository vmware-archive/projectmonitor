require 'spec_helper'

describe CircleCiProject do

  describe 'validations' do
    it { should validate_presence_of(:circleci_project_name) }
    it { should validate_presence_of(:circleci_auth_token) }
    it { should validate_presence_of(:circleci_username) }
  end

  subject { FactoryGirl.build(:circleci_project) }

  describe 'factories' do
    it { should be_valid }
  end

  describe 'model' do
    it { should validate_presence_of(:circleci_auth_token) }
    it { should validate_presence_of(:circleci_project_name) }
  end

  describe 'accessors' do
    its(:feed_url) { should == 'https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2' }
    its(:build_status_url) { should == 'https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2' }
    its(:current_build_url) { should == 'https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2' }
    its(:circleci_project_name) { should == 'a-project' }
    its(:fetch_payload) { should be_an_instance_of(CircleCiPayload) }
  end
end
