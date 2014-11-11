require 'spec_helper'

describe CodeshipProject, :type => :model do
  subject { build(:codeship_project) }

  describe 'validations' do
    context 'with webhooks disabled' do
      it { is_expected.to validate_presence_of :ci_build_identifier }
      it { is_expected.to validate_presence_of :ci_auth_token }
    end

    context 'with webhooks enabled' do
      before(:each) { subject.webhooks_enabled = true }

      it { is_expected.to_not validate_presence_of :ci_auth_token }
    end
  end

  describe '#feed_url' do
    it { expect(subject.feed_url).to eq 'https://www.codeship.io/api/v1/projects/1234.json?api_key=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2' }
  end

  describe '#build_status_url' do
    it { expect(subject.build_status_url).to eq subject.feed_url }
  end

  describe '#fetch_payload' do
    it { expect(subject.fetch_payload).to be_an_instance_of(CodeshipPayload) }
  end

  describe '#webook_payload' do
    it { expect(subject.webhook_payload).to be_an_instance_of(CodeshipPayload) }
  end
end
