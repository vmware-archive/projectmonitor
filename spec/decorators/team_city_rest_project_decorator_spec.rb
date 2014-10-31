require 'spec_helper'

describe TeamCityRestProjectDecorator do

  describe '#current_build_url' do
    subject { project.decorate.current_build_url }
    context "webhooks are disabled" do
      let(:project) { build(:team_city_rest_project) }

      it { is_expected.to eq('http://example.com/viewType.html?tab=buildTypeStatusDiv&buildTypeId=bt456') }
    end

    context "webhooks are enabled" do
      let(:project) { build(:team_city_rest_project, webhooks_enabled: true, parsed_url: 'foo.gov') }

      it { is_expected.to eq('http://foo.gov') }
    end
  end

end
