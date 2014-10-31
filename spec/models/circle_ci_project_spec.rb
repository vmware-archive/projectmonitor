require 'spec_helper'

describe CircleCiProject, :type => :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:circleci_project_name) }
    it { is_expected.to validate_presence_of(:circleci_auth_token) }
    it { is_expected.to validate_presence_of(:circleci_username) }
  end

  subject { build(:circleci_project) }

  describe 'model' do
    it { is_expected.to validate_presence_of(:circleci_auth_token) }
    it { is_expected.to validate_presence_of(:circleci_project_name) }
  end

  describe 'accessors' do
    describe '#feed_url' do
      subject { super().feed_url }
      it { is_expected.to eq('https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
    end

    describe '#build_status_url' do
      subject { super().build_status_url }
      it { is_expected.to eq('https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
    end

    describe '#circleci_project_name' do
      subject { super().circleci_project_name }
      it { is_expected.to eq('a-project') }
    end

    describe '#fetch_payload' do
      subject { super().fetch_payload }
      it { is_expected.to be_an_instance_of(CircleCiPayload) }
    end
  end
end
