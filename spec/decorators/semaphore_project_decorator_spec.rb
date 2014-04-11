require 'spec_helper'

describe SemaphoreProjectDecorator do
  let(:semaphore_project) { FactoryGirl.build(:semaphore_project) }

  subject { semaphore_project.decorate }

  its(:current_build_url) { should == nil }
end
