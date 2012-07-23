class TeamCityChainedPayloadProcessor < TeamCityPayloadProcessor
  def parse_building_status
    (live_builds.present? && live_builds.first[:running]) || project.children.any?(&:building?)
  end

  def parse_project_status
    status = build_live_statuses.last
    if status && status.success?
      status.success = false if project.children.any?(&:red?)
      status.published_at = [status.published_at, *project.children.map(&:last_build_time)].max
      project.statuses.create!(status.attributes)
    end
    project.online!
    status
  end
end
