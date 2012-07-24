require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject'],
                 ['Jenkins Project', 'JenkinsProject'],
                 ['Team City Rest Project', 'TeamCityRestProject'],
                 ['Team City Project', 'TeamCityProject'],
                 ['Team City Chained Project', 'TeamCityChainedProject'],
                 ['Travis Project', 'TravisProject']]
    end
  end

end
