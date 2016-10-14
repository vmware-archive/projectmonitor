class ProjectUpdater
  def initialize(payload_processor, polling_strategy_factory)
    @payload_processor = payload_processor
    @polling_strategy_factory = polling_strategy_factory
  end

  def update(project)
    payload = project.fetch_payload

    begin
      payload.status_content = fetch_status(project, project.feed_url)
      payload.build_status_content = fetch_status(project, project.build_status_url) unless project.feed_url == project.build_status_url

      log = @payload_processor.process_payload(project: project, payload: payload)
      log.update_method = "Polling"
      if project.persisted?
        log.save!
      end

      log
    rescue => e
      project.online = false
      project.building = false
      backtrace = "#{e.message}\n#{e.backtrace.join("\n")}"
      project.payload_log_entries.build(error_type: "#{e.class}", error_text: "#{e.message}", update_method: "Polling", status: "failed", backtrace: backtrace)
    end
  end

  private

  def fetch_status(project, url)
    response_body = nil

    EM.run do
      strategy = @polling_strategy_factory.build_ci_strategy(project)
      strategy.fetch_status(project, url) do |_, response_or_error, status_code|
        EM.stop

        case status_code
          when 200..299
            response_body = response_or_error
          else
            raise Net::HTTPError.new("Got #{status_code} response status from #{url}, body = '#{response_or_error}'", nil)
        end
      end
    end

    response_body
  end
end
