require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject', {'data-feed-url-fields'=>'URL'}],
                 ['Jenkins Project', 'JenkinsProject', {'data-feed-url-fields'=>'URL,Build Name'}],
                 ['Team City Rest Project', 'TeamCityRestProject', {'data-feed-url-fields'=>'URL,Build Type ID'}],
                 ['Team City Project', 'TeamCityProject', {'data-feed-url-fields'=>'URL,Build ID'}],
                 ['Team City Chained Project', 'TeamCityChainedProject', {'data-feed-url-fields'=>'URL,Build Type ID'}],
                 ['Travis Project', 'TravisProject', {'data-feed-url-fields'=>'Account,Project'}]]
    end
  end

end
