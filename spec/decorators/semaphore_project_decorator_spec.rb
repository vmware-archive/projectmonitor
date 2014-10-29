require 'spec_helper'

describe SemaphoreProjectDecorator do
  let(:semaphore_project) { FactoryGirl.build(:semaphore_project) }

  subject { semaphore_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq(nil) }
  end
end
