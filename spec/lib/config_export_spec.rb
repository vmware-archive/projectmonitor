require 'spec_helper'

describe ConfigExport do

  context 'given a full set of configuration records' do
    let(:aggregate_project) { stub_model(AggregateProject, name: 'agg', id: 1, tag_list: [])}
    let(:solo_project) { FactoryGirl.build(:jenkins_project, name: 'Foo', tag_list: %w[foo bar baz]) }
    let(:aggregated_project) { FactoryGirl.build(:travis_project, name: 'Led', aggregate_project_id: 1) }
    let(:projects) do
      [solo_project, aggregated_project]
    end
    let(:aggregate_projects) { [aggregate_project] }

    before do
      aggregate_project.stub(:id).and_return(1)
      Project.stub(:all).and_return(projects)
      AggregateProject.stub(:all).and_return(aggregate_projects)
    end

    it 'can export and import those records' do
      AggregateProject
        .should_receive(:create!)
        .with('name' => 'agg', 'enabled' => true, 'tag_list' => [])
        .and_return(aggregate_project)
      Project
        .should_receive(:create!)
        .with('name' => 'Foo',
              'deprecated_feed_url' => nil,
              'auth_username' => nil,
              'auth_password' => nil,
              'enabled' => true,
              'type' => 'JenkinsProject',
              'polling_interval' => nil,
              'aggregate_project_id' => nil,
              'deprecated_latest_status_id' => nil,
              'code' => nil,
              'tracker_project_id' => nil,
              'tracker_auth_token' => nil,
              'cruise_control_rss_feed_url' => nil,
              'jenkins_base_url' => 'http://www.example.com',
              'jenkins_build_name' => 'project',
              'team_city_base_url' => nil,
              'team_city_build_id' => nil,
              'team_city_rest_base_url' => nil,
              'team_city_rest_build_type_id' => nil,
              'travis_github_account' => nil,
              'travis_repository' => nil,
              'tag_list' => ['foo', 'bar', 'baz'])
      Project
        .should_receive(:create!)
        .with(hash_including('name' => 'Led', 'aggregate_project_id' => 1))

      ConfigExport.import ConfigExport.export
    end
  end

end
