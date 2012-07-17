class TravisPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    building = false
    begin
      json = JSON.parse(payload).first
      building = json["state"] == "started" if json
    rescue JSON::ParserError; end
    building
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)
    begin
      if json = JSON.parse(payload).first
        status.success = json["result"].to_i == 0
        status.url = project.feed_url.gsub(".json", "/#{json["id"]}")
        published_at = json["finished_at"]
        status.published_at = Time.parse(published_at).localtime if published_at.present?
      end
    rescue JSON::ParserError; end
    status
  end
end
