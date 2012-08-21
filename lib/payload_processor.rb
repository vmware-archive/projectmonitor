class PayloadProcessor
  attr_accessor :project, :payload

  def initialize(project, payload)
    self.project = project
    self.payload = payload
  end

  def process
    add_statuses
    update_building_status
    payload_log
  end

  private

  def payload_log
    success = payload.status_is_processable? || payload.build_status_is_processable?
    status = success ? "successful" : "failed"
    project.payload_log_entries.build(status: status, error_text: payload.error_text.join("\n"))
  end

  def add_statuses
    if payload.status_is_processable?
      project.online = true
      project.parsed_url = payload.parsed_url if payload.parsed_url.present?
      add_statuses_from_payload
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
      project.statuses.push status
    end
  end

end
