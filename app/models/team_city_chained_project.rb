class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def fetch_new_statuses
    parsed_status = parse_project_status
    parsed_status.online = true
    statuses.create(parsed_status.attributes) unless status.match?(parsed_status)
  end

  def fetch_building_status
    my_building_status = super
    return my_building_status if my_building_status.building?
    BuildingStatus.new( children.any?(&:building?) )
  end

  private

  def parse_project_status
    status = build_live_statuses.first
    return status unless status.success?
    status.success = false if children.any?(&:red?)
    status.published_at = [status.published_at, *children.map(&:last_build_time)].max
    status
  end
end
