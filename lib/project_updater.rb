class ProjectUpdater
  def initialize(payload_processor: )
    @payload_processor = payload_processor
  end

  def update(project)
    payload = project.fetch_payload

    begin
      fetch_status(project, payload)
      fetch_building_status(project, payload) unless project.feed_url == project.build_status_url

      log = @payload_processor.process_payload(project: project, payload: payload)
      log.update_method = "Polling"
      log.save!

      log
    rescue => e
      project.online = false
      project.building = false
      backtrace = "#{e.message}\n#{e.backtrace.join("\n")}"
      project.payload_log_entries.build(error_type: "#{e.class}", error_text: "#{e.message}", update_method: "Polling", status: "failed", backtrace: backtrace)
    end
  end

  private

  def fetch_status(project, payload)
    retriever = UrlRetriever.new(project.feed_url, project.auth_username, project.auth_password, project.verify_ssl)
    payload.status_content = retriever.retrieve_content
  end

  def fetch_building_status(project, payload)
    retriever = UrlRetriever.new(project.build_status_url, project.auth_username, project.auth_password, project.verify_ssl)
    payload.build_status_content = retriever.retrieve_content
  end
end
