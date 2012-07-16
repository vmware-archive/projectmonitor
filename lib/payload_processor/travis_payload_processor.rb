class TravisPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    building_status = BuildingStatus.new(false)
    begin
      json = JSON.parse(payload).first
      building_status.building = json["state"] == "started" if json
    rescue JSON::ParserError; end
    building_status
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)
    begin
      if json = JSON.parse(payload).first
        status.success = json["result"] == 0
        status.url = project.feed_url
        published_at = json["finished_at"]
        status.published_at = Time.parse(published_at).localtime if published_at.present?
      end
    rescue JSON::ParserError; end
    status
  end
end
