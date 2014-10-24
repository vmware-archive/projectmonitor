require 'spec_helper'

describe ConcourseProjectDecorator do
  let(:concourse_project) { FactoryGirl.build(:concourse_project) }

  subject { concourse_project.decorate }

  its(:current_build_url) { should == 'http://concourse.example.com:8080/jobs/concourse-project' }
end
