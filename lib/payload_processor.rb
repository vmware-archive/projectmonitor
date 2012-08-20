class PayloadProcessor
  attr_accessor :project, :payload

  def initialize(project, payload)
    self.project = project
    self.payload = payload
  end

  def process
    add_statuses
    update_building_status
  end

  private

  def add_statuses
    if payload.status_is_processable?
      project.online = true
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
      project.statuses << status
    end
  end

end
