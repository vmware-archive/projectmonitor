require 'spec_helper'

describe CodeshipProjectDecorator do
  let(:codeship_project) { build(:codeship_project) }

  subject { codeship_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('https://www.codeship.io/projects/1234') }
  end
end
