require 'spec_helper'

describe ProjectsHelper do

  describe '#project_types' do
    subject { helper.project_types }
    it do
      should == [['', ''],
                 ['Cruise Control Project', 'CruiseControlProject', {'data-feed-url-fields'=>'Cc Rss Feed URL'}],
                 ['Jenkins Project', 'JenkinsProject', {'data-feed-url-fields'=>'Jenkins Base URL,Jenkins Build Name'}],
                 ['Team City Rest Project', 'TeamCityRestProject', {'data-feed-url-fields'=>'Teamcity Rest Base URL,Teamcity Rest Build Type ID'}],
                 ['Team City Project', 'TeamCityProject', {'data-feed-url-fields'=>'Teamcity Base URL,Teamcity Build ID'}],
                 ['Team City Chained Project', 'TeamCityChainedProject', {'data-feed-url-fields'=>'Teamcity Rest Base URL,Teamcity Rest Build Type ID'}],
                 ['Travis Project', 'TravisProject', {'data-feed-url-fields'=>'Travis Github Account,Travis Repository'}]]
    end
  end

end
