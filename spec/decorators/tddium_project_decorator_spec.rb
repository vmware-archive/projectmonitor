require 'spec_helper'

describe TddiumProjectDecorator do
  let(:tddium_project) { build(:tddium_project) }

  subject { tddium_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('https://api.tddium.com/dashboard?auth_token=b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2') }
  end
end
