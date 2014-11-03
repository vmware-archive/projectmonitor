require 'spec_helper'

describe CircleCiProject, :type => :model do

  describe 'validations' do
    it { is_expected.to validate_presence_of(:ci_build_name) }
    it { is_expected.to validate_presence_of(:circleci_auth_token) }
    it { is_expected.to validate_presence_of(:circleci_username) }
  end

  subject { build(:circleci_project) }

  describe 'model' do
    it { is_expected.to validate_presence_of(:circleci_auth_token) }
    it { is_expected.to validate_presence_of(:ci_build_name) }
  end

  describe 'accessors' do
    describe '#feed_url' do
      it { expect(subject.feed_url).to eq('https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
    end

    describe '#build_status_url' do
      it { expect(subject.build_status_url).to eq('https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
    end

    describe '#ci_build_name' do
      it { expect(subject.ci_build_name).to eq('a-project') }
    end

    describe '#fetch_payload' do
      it { expect(subject.fetch_payload).to be_an_instance_of(CircleCiPayload) }
    end
  end
end
