FactoryGirl.define do
  factory :project, class: JenkinsProject do
    name { Faker::Name.name }
    jenkins_base_url "http://www.example.com"
    jenkins_build_name "project"

    factory :project_with_tracker_integration do
      tracker_project_id "123"
      tracker_auth_token "foo"
      tracker_online true
      current_velocity 15
      stories_to_accept_count 7
      open_stories_count 16
      last_ten_velocities [ 1,2,3,4,5,6,7,8,9,10 ]
    end

    factory :jenkins_project
  end

  factory :travis_project, class: TravisProject do
    name { Faker::Name.name }
    travis_github_account "account"
    travis_repository "project"
  end

  factory :cruise_control_project, class: CruiseControlProject do
    name { Faker::Name.name }
    cruise_control_rss_feed_url "http://www.example.com/project.rss"
  end

  factory :team_city_project, class: TeamCityProject do
    name { Faker::Name.name }
    team_city_base_url "foo.bar.com:1234"
    team_city_build_id "bt567"
  end

  factory :team_city_rest_project, class: TeamCityRestProject do
    name { Faker::Name.name }
    team_city_rest_base_url "example.com"
    team_city_rest_build_type_id "bt456"
  end

  factory :semaphore_project, class: SemaphoreProject do
    name { Faker::Name.name }
    semaphore_api_url 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh'
  end

  factory :tddium_project, class: TddiumProject do
    name { Faker::Name.name }
    tddium_auth_token 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2'
    tddium_project_name 'Test Project A'
  end
end
