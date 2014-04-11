require 'spec_helper'

describe TeamCityRestProjectDecorator do

  describe '#current_build_url' do
    subject { project.decorate.current_build_url }
    context "webhooks are disabled" do
      let(:project) { FactoryGirl.build(:team_city_rest_project) }

      it { should == 'http://example.com/viewType.html?tab=buildTypeStatusDiv&buildTypeId=bt456' }
    end

    context "webhooks are enabled" do
      let(:project) { FactoryGirl.build(:team_city_rest_project, webhooks_enabled: true, parsed_url: 'foo.gov') }

      it { should == 'http://foo.gov' }
    end
  end

end
