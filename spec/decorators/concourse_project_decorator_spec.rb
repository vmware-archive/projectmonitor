require 'spec_helper'

describe ConcourseProjectDecorator do
  let(:concourse_project) { FactoryGirl.build(:concourse_project) }

  subject { concourse_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('http://concourse.example.com:8080/jobs/concourse-project') }
  end
end
