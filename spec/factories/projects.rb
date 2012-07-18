FactoryGirl.define do
  factory :project, class: JenkinsProject do
    name { Faker::Name.name }
    url "http://www.example.com"
    build_name "project"

    factory :project_with_tracker_integration do
      tracker_project_id "123"
      tracker_auth_token "foo"
      tracker_online true
    end
  end

  factory :travis_project, class: TravisProject do
    name { Faker::Name.name }
    account "account"
    project "project"
  end

  factory :jenkins_project, class: JenkinsProject do
    name { Faker::Name.name }
    url "http://www.example.com"
    build_name "project"
  end

  factory :cruise_control_project, class: CruiseControlProject do
    name { Faker::Name.name }
    url "http://www.example.com/project.rss"
  end

  factory :team_city_rest_project, class: TeamCityRestProject do
    name { Faker::Name.name }
    url "example.com"
    build_type_id "bt456"
  end

  factory :team_city_project, class: TeamCityProject do
    name { Faker::Name.name }
    url "foo.bar.com:1234"
    build_type_id "bt567"
  end
end
