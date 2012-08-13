FactoryGirl.define do
  factory :project, class: JenkinsProject do
    name { Faker::Name.name }
    jenkins_base_url "http://www.example.com"
    jenkins_build_name "project"

    factory :project_with_tracker_integration do
      tracker_project_id "123"
      tracker_auth_token "foo"
      tracker_online true
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
end
