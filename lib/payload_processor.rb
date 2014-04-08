class PayloadProcessor
  attr_accessor :project, :payload

  def initialize(project_status_updater: nil)
    @status_updater = project_status_updater
  end

  def process_payload(project: nil, payload: nil)
    self.project = project
    self.payload = payload
    add_statuses
    update_building_status
    payload_log
  end

  private

  def payload_log
    success = payload.status_is_processable? || payload.build_status_is_processable?
    status = success ? "successful" : "failed"
    project.payload_log_entries.build(status: status, error_type: "#{payload.error_type}", error_text: "#{payload.error_text}", backtrace: "#{payload.backtrace}")
  end

  def add_statuses
    if payload.status_is_processable?
      project.online = true
      add_statuses_from_payload
      project.parsed_url = payload.parsed_url if payload.parsed_url.present?
    else
      project.online = false
    end
  end

  def update_building_status
    project.building = payload.build_status_is_processable? && payload.building?
  end

  def add_statuses_from_payload
    payload.each_status do |status|
      next if project.has_status?(status)
      if status.valid?
        @status_updater.update_project(project, status)
      else
        project.payload_log_entries.build(error_type: "Status Invalid", error_text: error_text(status))
      end
    end
  end

  def error_text(status)
    <<-ERROR
Payload returned an invalid status: #{status.inspect}
  Errors: #{status.errors.full_messages.to_sentence}
  Payload: #{payload.inspect}
ERROR
  end

end
