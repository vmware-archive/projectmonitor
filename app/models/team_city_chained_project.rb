class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def process_status_update
    parsed_status = parse_project_status
    parsed_status.online = true
    statuses.create(parsed_status.attributes) unless status.match?(parsed_status)

  rescue Net::HTTPError => e
    error = "HTTP Error retrieving status for project '##{id}': #{e.message}"
    statuses.create(:error => error) unless status.error == error
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
