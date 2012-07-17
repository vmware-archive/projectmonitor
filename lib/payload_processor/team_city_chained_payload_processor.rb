class TeamCityChainedPayloadProcessor < TeamCityPayloadProcessor
  def parse_building_status
    (live_builds.present? && live_builds.first[:running]) || project.children.any?(&:building?)
  end

  def parse_project_status
    status = build_live_statuses.last
    return status unless status && status.success?
    if status
      status.success = false if project.children.any?(&:red?)
      status.published_at = [status.published_at, *project.children.map(&:last_build_time)].max
    end
    status
  end
end
