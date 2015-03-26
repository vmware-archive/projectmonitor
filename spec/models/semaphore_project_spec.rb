require 'spec_helper'

describe SemaphoreProject, :type => :model do

  it { is_expected.to validate_presence_of(:semaphore_api_url) }

  subject { build(:semaphore_project) }

  describe '#feed_url' do
    it { expect(subject.feed_url).to eq('https://semaphoreci.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh') }
  end

  describe '#build_status_url' do
    it { expect(subject.build_status_url).to eq('https://semaphoreci.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh') }
  end

  describe '#fetch_payload' do
    it { expect(subject.fetch_payload).to be_an_instance_of(SemaphorePayload) }
  end

  describe '#webhook_payload' do
    it { expect(subject.webhook_payload).to be_an_instance_of(SemaphorePayload) }
  end

end
