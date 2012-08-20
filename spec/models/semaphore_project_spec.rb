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

  its(:fetch_payload) { should be_an_instance_of(SemaphorePayload) }
  its(:webhook_payload) { should be_an_instance_of(SemaphorePayload) }

  describe '#current_build_url' do
    subject { project.current_build_url }
    context "webhooks are disabled" do
      let(:project) { FactoryGirl.build(:semaphore_project) }

      it { should == 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh' }
    end

    context "webhooks are enabled" do
      let(:project) { FactoryGirl.build(:semaphore_project, webhooks_enabled: true, parsed_url: 'foo.gov') }

      it { should == 'foo.gov' }
    end
  end
end
