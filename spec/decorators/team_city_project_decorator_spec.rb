require 'spec_helper'

describe TeamCityProjectDecorator do
  let(:team_city_project) { FactoryGirl.build(:team_city_project) }

  subject { team_city_project.decorate }

  its(:current_build_url) { should == 'foo.bar.com:1234/viewType.html?buildTypeId=bt567' }
end
