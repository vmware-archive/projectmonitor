FactoryGirl.define do
  sequence(:name) {|n| "#{@instance.class.name} #{n}"}

  factory :project, class: JenkinsProject do
    name
    ci_base_url "http://www.example.com"
    ci_build_identifier "project"

    factory :project_with_tracker_integration do
      tracker_project_id "123"
      tracker_auth_token "foo"
      tracker_online true
      current_velocity 15
      stories_to_accept_count 7
      open_stories_count 16
      last_ten_velocities [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    factory :jenkins_project
  end

  factory :travis_project, class: TravisProject do
    name
    travis_github_account "account"
    travis_repository "project"
  end

  factory :cruise_control_project, class: CruiseControlProject do
    name
    cruise_control_rss_feed_url "http://www.example.com/project.rss"
  end

  factory :team_city_project, class: TeamCityProject do
    name
    ci_base_url "foo.bar.com:1234"
    ci_build_identifier "bt567"
  end

  factory :team_city_rest_project, class: TeamCityRestProject do
    name
    ci_base_url "example.com"
    ci_build_identifier "bt456"
  end

  factory :semaphore_project, class: SemaphoreProject do
    name
    semaphore_api_url 'https://semaphoreapp.com/api/v1/projects/2fd4e1c67a2d28fced849ee1bb76e7391b93eb12/123/status?auth_token=nyargh'
  end

  factory :tddium_project, class: TddiumProject do
    name
    tddium_auth_token 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2'
    ci_build_identifier 'Test Project A'
  end

  factory :circleci_project, class: CircleCiProject do
    name
    circleci_auth_token 'b5bb9d8014a0f9b1d61e21e796d78dccdf1352f2'
    ci_build_identifier 'a-project'
    circleci_username 'username'
  end

  factory :concourse_project, class: ConcourseProject do
    name
    ci_build_identifier 'concourse-project'
    ci_base_url 'http://concourse.example.com:8080'
  end
end
