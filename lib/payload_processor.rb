class PayloadProcessor
  attr_accessor :project, :payload

  def initialize(project, payload)
    self.project = project
    self.payload = payload
  end

  def process
    create_statuses
    update_building_status
  end

  private

  def create_statuses
    return unless payload.status_is_processable?

    project.online!
    statuses_from_payloads.each do |status|
      project.statuses.create!(status.attributes) unless project.has_status?(status)
    end
  end

  def update_building_status
    return unless payload.build_status_is_processable?
    project.update_attributes!(building: payload.building?)
  end

  def statuses_from_payloads
    payload.each_status do |payload_status|
      status = ProjectStatus.new
      status.success = payload_status.success
      status.url = payload_status.url
      status.build_id = payload_status.build_id
      status.published_at = payload_status.published_at
      next unless status.valid?

      status
    end.compact
  end
end
