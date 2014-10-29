require 'spec_helper'

describe TddiumProject, :type => :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:tddium_project_name) }
    it { is_expected.to validate_presence_of(:tddium_auth_token) }
  end

  subject { FactoryGirl.build(:tddium_project) }

  describe 'factories' do
    it { is_expected.to be_valid }
  end

  describe 'model' do
    it { is_expected.to validate_presence_of(:tddium_auth_token) }
    it { is_expected.to validate_presence_of(:tddium_project_name) }
  end

  describe 'accessors' do
    describe '#feed_url' do
      subject { super().feed_url }
      it { is_expected.to eq('https://api.tddium.com/cc/b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2/cctray.xml') }
    end

    describe '#build_status_url' do
      subject { super().build_status_url }
      it { is_expected.to eq('https://api.tddium.com/cc/b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2/cctray.xml') }
    end

    describe '#tddium_project_name' do
      subject { super().tddium_project_name }
      it { is_expected.to eq('Test Project A') }
    end

    describe '#fetch_payload' do
      subject { super().fetch_payload }
      it { is_expected.to be_an_instance_of(TddiumPayload) }
    end
  end
end
