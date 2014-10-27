require 'spec_helper'

describe CircleCiProjectDecorator do
  let(:circleci_project) { FactoryGirl.build(:circleci_project) }

  subject { circleci_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('https://circleci.com/api/v1/project/username/a-project?circle-token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
  end
end
