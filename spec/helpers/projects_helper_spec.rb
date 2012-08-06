require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject'],
                 ['Jenkins Project', 'JenkinsProject'],
                 ['Team City Project', 'TeamCityRestProject'],
                 ['Team City Project with Dependencies', 'TeamCityChainedProject'],
                 ['Legacy Team City (<= v6) Project', 'TeamCityProject'],
                 ['Travis Project', 'TravisProject']]
    end
  end

end
