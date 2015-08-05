require 'spec_helper'

describe ConcourseProject, :type => :model do
  subject { build(:concourse_project) }

  describe 'validations' do
    it { is_expected.to validate_presence_of :ci_base_url }
    it { is_expected.to validate_presence_of :concourse_pipeline_name }
    it { is_expected.to validate_presence_of :ci_build_identifier }
  end

  describe 'accessors' do
    describe '#feed_url' do
      it { expect(subject.feed_url).to eq('http://concourse.example.com:8080/api/v1/pipelines/concourse-pipeline/jobs/concourse-project/builds') }
    end

    describe '#build_status_url' do
      it { expect(subject.build_status_url).to eq('http://concourse.example.com:8080/api/v1/pipelines/concourse-pipeline/jobs/concourse-project/builds') }
    end

    describe '#ci_build_identifier' do
      it { expect(subject.ci_build_identifier).to eq('concourse-project') }
    end

    describe '#fetch_payload' do
      it { expect(subject.fetch_payload).to be_an_instance_of(ConcoursePayload)  }
    end
  end
end
