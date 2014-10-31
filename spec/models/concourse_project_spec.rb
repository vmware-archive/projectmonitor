require 'spec_helper'

describe ConcourseProject, :type => :model do
  subject { build(:concourse_project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of :concourse_base_url }
    it { is_expected.to validate_presence_of :concourse_job_name }
  end

  describe 'accessors' do
    describe '#feed_url' do
      subject { super().feed_url }
      it { is_expected.to eq('http://concourse.example.com:8080/api/v1/jobs/concourse-project/builds') }
    end

    describe '#build_status_url' do
      subject { super().build_status_url }
      it { is_expected.to eq('http://concourse.example.com:8080/api/v1/jobs/concourse-project/builds') }
    end

    describe '#concourse_job_name' do
      subject { super().concourse_job_name }
      it { is_expected.to eq('concourse-project') }
    end

    describe '#fetch_payload' do
      subject { super().fetch_payload }
      it { is_expected.to be_an_instance_of(ConcoursePayload)  }
    end
  end
end
