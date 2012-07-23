class ProjectPayloadProcessor
  attr_accessor :project, :payload

  def initialize(project, payload)
    self.project = project
    self.payload = payload
  end

  def fetch_new_statuses
    parsed_status = if detect_json?
      parse_project_status_from_json
    else
      parse_project_status
    end
    if parsed_status
      unless project.status.match?(parsed_status)
        project.statuses.create!(parsed_status.attributes)
        project.online!
      end
    end
  end

  def fetch_building_status
    building_status = if detect_json?
      parse_building_status_from_json
    else
      parse_building_status
    end
    project.update_attribute(:building, building_status)
  end

  def perform
    project.processor.new(project, payload).process
  end

  def detect_json?
    false
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
