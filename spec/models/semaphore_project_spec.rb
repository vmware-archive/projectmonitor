require 'spec_helper'

describe SemaphoreProject do

  it { should validate_presence_of(:semaphore_api_url) }

  subject { FactoryGirl.build(:semaphore_project) }

  describe 'factories' do
    subject { FactoryGirl.build(:semaphore_project) }
    it { should be_valid }
  end

  its(:feed_url) { should == 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh' }
  its(:build_status_url) { should == 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh' }
  its(:current_build_url) { should be_nil }

  its(:fetch_payload) { should be_an_instance_of(SemaphorePayload) }
  its(:webhook_payload) { should be_an_instance_of(SemaphorePayload) }

end
