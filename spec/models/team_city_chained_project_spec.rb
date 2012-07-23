require 'spec_helper'

describe TeamCityChainedProject do

  describe 'factories' do
    subject { FactoryGirl.build(:team_city_chained_project) }
    it { should be_valid }
  end

end
