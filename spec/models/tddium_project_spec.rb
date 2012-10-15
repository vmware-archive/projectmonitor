require 'spec_helper'

describe TddiumProject do

  describe 'validations' do
    it { should validate_presence_of(:tddium_project_name) }
    it { should validate_presence_of(:tddium_auth_token) }
  end

  subject { FactoryGirl.build(:tddium_project) }

  describe 'factories' do
    it { should be_valid }
  end

  describe 'model' do
    it { should validate_presence_of(:tddium_auth_token) }
    it { should validate_presence_of(:tddium_project_name) }
  end

  describe 'accessors' do
    its(:feed_url) { should == 'https://api.tddium.com/cc/b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2/cctray.xml' }
    its(:build_status_url) { should == 'https://api.tddium.com/cc/b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2/cctray.xml' }
    its(:current_build_url) { should == 'https://api.tddium.com/dashboard?auth_token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2' }
    its(:tddium_project_name) { should == 'Test Project A' }
    its(:fetch_payload) { should be_an_instance_of(TddiumPayload) }
  end
end
