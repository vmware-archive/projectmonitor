require 'spec_helper'

describe TeamCityProjectDecorator do
  let(:team_city_project) { build(:team_city_project) }

  subject { team_city_project.decorate }

  describe '#current_build_url' do
    subject { super().current_build_url }
    it { is_expected.to eq('foo.bar.com:1234/viewType.html?buildTypeId=bt567') }
  end
end
