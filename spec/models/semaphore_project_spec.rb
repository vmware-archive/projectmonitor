require 'spec_helper'

describe SemaphoreProject, :type => :model do

  it { is_expected.to validate_presence_of(:semaphore_api_url) }

  subject { FactoryGirl.build(:semaphore_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:semaphore_project) }
    it { is_expected.to be_valid }
  end

  describe '#feed_url' do
    subject { super().feed_url }
    it { is_expected.to eq('https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh') }
  end

  describe '#build_status_url' do
    subject { super().build_status_url }
    it { is_expected.to eq('https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh') }
  end

  describe '#fetch_payload' do
    subject { super().fetch_payload }
    it { is_expected.to be_an_instance_of(SemaphorePayload) }
  end

  describe '#webhook_payload' do
    subject { super().webhook_payload }
    it { is_expected.to be_an_instance_of(SemaphorePayload) }
  end

end
