class TeamCityChainedPayloadProcessor < TeamCityPayloadProcessor
  def parse_building_status
    my_building_status = super
    return my_building_status if my_building_status.building?
    BuildingStatus.new( project.children.any?(&:building?) )
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
