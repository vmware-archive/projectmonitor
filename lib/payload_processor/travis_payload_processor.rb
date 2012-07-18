class TravisPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    building = false
    if parse_payload!
      building = payload["state"] == "started" if payload
    end
    building
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)
    if parse_payload!
      status.success = payload["result"].to_i == 0
      status.url = project.feed_url.gsub(".json", "/#{payload["id"]}")
      published_at = payload["finished_at"]
      status.build_id = payload["id"]
      status.published_at = Time.parse(published_at).localtime if published_at.present?
    end
    status
  end

  def parse_payload!
    @parsed ||=
      begin
        self.payload = payload.fetch("payload", payload) if payload.respond_to?(:fetch)
        self.payload = Array.wrap(JSON.parse(payload)).first if payload
        true
      rescue JSON::ParserError
        false
      end
  end
end
