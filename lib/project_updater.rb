module ProjectUpdater

  class << self

    def update(project)
      update_status(project)
      project.last_refreshed_at = Time.now
    end

  private

    def update_status(project)
      payload = project.fetch_payload

      begin
        fetch_status(project, payload)
        fetch_building_status(project, payload) unless project.feed_url == project.build_status_url

        PayloadProcessor.new(project, payload).process

        if project.has_dependencies?
          fetch_dependent_project_info(project, payload)
          update_children(project, payload)
        end

      rescue Net::HTTPError => e
        project.online = false
        project.building = false
      end
    end

    def update_children(project, payload)
      project.has_failing_children = false
      project.has_building_children = false

      payload.each_child(project) do |child_project|
        update_status(child_project)

        project.has_failing_children ||= child_project.red?
        project.has_building_children ||= child_project.building?
      end
    end

    def fetch_status(project, payload)
      payload.status_content = UrlRetriever.retrieve_content_at(project.feed_url, project.auth_username, project.auth_password)
    end

    def fetch_building_status(project, payload)
      payload.build_status_content = UrlRetriever.retrieve_content_at(project.build_status_url, project.auth_username, project.auth_password)
    end

    def fetch_dependent_project_info(project, payload)
      payload.dependent_content = UrlRetriever.retrieve_content_at(project.dependent_build_info_url, project.auth_username, project.auth_password)
    end

  end

end
