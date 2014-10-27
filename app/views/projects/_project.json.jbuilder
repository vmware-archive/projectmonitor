json.(project,
    :id,
    :name,
    :enabled,
    :code,
    :tag_list,
    :created_at,
    :updated_at,
    :deprecated_location,
    :tracker_project_id,
    :current_velocity,
    :last_ten_velocities,
    :tracker_online,
    :cruise_control_rss_feed_url,
    :jenkins_base_url,
    :jenkins_build_name,
    :team_city_base_url,
    :team_city_build_id,
    :team_city_rest_base_url,
    :team_city_rest_build_type_id,
    :travis_github_account,
    :travis_repository,
    :guid,
    :webhooks_enabled,
    :tracker_validation_status,
    :last_refreshed_at,
    :semaphore_api_url,
    :parsed_url,
    :tddium_auth_token,
    :tddium_project_name,
    :notification_email,
    :verify_ssl,
    :stories_to_accept_count,
    :open_stories_count,
    :build_branch,
    :iteration_story_state_counts,
    :creator_id,
    :circleci_auth_token,
    :circleci_project_name,
    :circleci_username,
    :concourse_base_url,
    :concourse_job_name)

if project.tracker_project_id.present?
  json.tracker do
    json.(project,
        :tracker_online,
        :current_velocity,
        :last_ten_velocities,
        :stories_to_accept_count,
        :open_stories_count,
        :iteration_story_state_counts,
        :volatility)
  end
end

json.project_id           project.id
json.building             project.building?
json.online               project.online?
json.aggregate_project_id nil

json.build do
  json.(project, :id, :code, :published_at, :current_build_url)
  json.building project.building?
  json.status   project.status_in_words

  json.statuses project.statuses.recent do |status|
    json.(status, :success, :url)
  end
end