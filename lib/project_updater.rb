module ProjectUpdater

  class << self

    def update(project)
      payload = project.fetch_payload

      begin
        fetch_status(project, payload)
        fetch_building_status(project, payload) unless project.feed_url == project.build_status_url

        update_dependents(project, payload)

        log = PayloadProcessor.new(project, payload).process
        log.method = "Polling"
        log.save!

        #maybe remove this

        if project.has_dependencies? && log.status == "successful"
          fetch_dependent_project_info(project, payload)
          update_children(project, payload)
        end

        ####
        #
        log
      rescue => e
        project.online = false
        project.building = false
        backtrace = "#{e.message}\n#{e.backtrace.join("\n")}"
        project.payload_log_entries.build(error_type: e.class.to_s, error_text: e.message, method: "Polling", status: "failed", backtrace: backtrace)
      end
    end

  private

    def update_dependent(project)
      update(project)
    end

    def update_dependents(project, payload)
      return unless project.persisted? && project.dependent_build_info_url

      fetch_dependent_project_info(project, payload)
      project.dependent_projects.each {|p| update_dependent(p)}
    end

    def fetch_status(project, payload)
      retriever = UrlRetriever.new(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl)
      payload.status_content = retriever.retrieve_content
    end

    def fetch_building_status(project, payload)
      retriever = UrlRetriever.new(project.build_status_url, project.auth_username, project.auth_password, project.verify_ssl)
      payload.build_status_content = retriever.retrieve_content
    end

    def fetch_dependent_project_info(project, payload)
      retriever = UrlRetriever.new(project.dependent_build_info_url, project.auth_username, project.auth_password, project.verify_ssl)
      payload.dependent_content = retriever.retrieve_content
    end

  end

end
