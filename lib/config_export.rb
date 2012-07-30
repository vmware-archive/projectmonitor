module ConfigExport
  PROJECT_ATTRIBUTES = %w[name
                          deprecated_feed_url
                          auth_username
                          auth_password
                          enabled
                          type
                          polling_interval
                          aggregate_project_id
                          deprecated_latest_status_id
                          ec2_monday
                          ec2_tuesday
                          ec2_wednesday
                          ec2_thursday
                          ec2_friday
                          ec2_saturday
                          ec2_sunday
                          ec2_start_time
                          ec2_end_time
                          ec2_access_key_id
                          ec2_secret_access_key
                          ec2_instance_id
                          ec2_elastic_ip
                          code
                          location
                          tracker_project_id
                          tracker_auth_token
                          cruise_control_rss_feed_url
                          jenkins_base_url
                          jenkins_build_name
                          team_city_base_url
                          team_city_build_id
                          team_city_rest_base_url
                          team_city_rest_build_type_id
                          travis_github_account
                          travis_repository]
  AGGREGATE_PROJECT_ATTRIBUTES = %w[id name enabled]

  class << self
    def export
      projects = Project.all.map do |project|
        exported_project_attributes(project)
      end

      aggregate_projects = AggregateProject.all.map do |ap|
        exported_aggregate_project_attributes(ap)
      end

      {'aggregate_projects' => aggregate_projects,
       'projects' => projects}.to_yaml
    end

    def import(config)
      config = YAML.load(config)

      cached_agg = {}
      config['aggregate_projects'].each do |aggregate_project|
        cached_agg[aggregate_project['id']] = AggregateProject.create!(aggregate_project.except('id'))
      end

      config['projects'].each do |project_attributes|
        project_attributes['type'].constantize.create!(project_attributes) do |project|
          project.aggregate_project_id = cached_agg[project_attributes['aggregate_project_id']].try(:id)
        end
      end
    end

    private

    def exported_project_attributes(project)
      attrs = project.attributes.slice(*PROJECT_ATTRIBUTES)
      attrs['tag_list'] = project.tag_list.to_a
      attrs
    end

    def exported_aggregate_project_attributes(ap)
      attrs = ap.attributes.slice(*AGGREGATE_PROJECT_ATTRIBUTES)
      attrs['tag_list'] = ap.tag_list.to_a
      attrs
    end
  end

end
