require 'spec_helper'

describe ConcourseV1ProjectDecorator do
  let(:concourse_v1_project) { build(:concourse_v1_project) }

  subject { concourse_v1_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('http://concourse.example.com:8080/jobs/concourse-project') }
  end
end
