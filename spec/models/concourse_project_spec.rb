require 'spec_helper'

describe ConcourseProject do
  subject { FactoryGirl.build(:concourse_project) }

  describe 'factories' do
    it { should be_valid }
  end

  describe 'validations' do
    it { should validate_presence_of :concourse_base_url }
    it { should validate_presence_of :concourse_job_name }
  end

  describe 'accessors' do
    its(:feed_url) { should == 'http://concourse.example.com:8080/api/v1/jobs/concourse-project/builds' }
    its(:build_status_url) { should == 'http://concourse.example.com:8080/api/v1/jobs/concourse-project/builds' }
    its(:concourse_job_name) { should == 'concourse-project' }
    its(:fetch_payload) { should be_an_instance_of(ConcoursePayload)  }
  end
end
