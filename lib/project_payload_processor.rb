class ProjectPayloadProcessor
  attr_accessor :project, :payload, :processor

  def initialize(project, payload)
    self.project = project
    self.payload = payload
  end

  def fetch_new_statuses
    parsed_status = parse_project_status
    if parsed_status
      parsed_status.online = true
      project.statuses.create!(parsed_status.attributes) unless project.status.match?(parsed_status)
    end
  end

  def find(document, path)
    document.css("#{path}") if document
  end

  def fetch_building_status
    building_status = parse_building_status
    project.update_attribute(:building, building_status.building?)
  end

  def perform
    project.processor.new(project, payload).process
  end

  def process
    fetch_new_statuses
    fetch_building_status
  end

  def parse_project_status
    raise NotImplementedError
  end

  def parse_building_status
    raise NotImplementedError
  end
end
