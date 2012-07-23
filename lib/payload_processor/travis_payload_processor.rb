class TravisPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    return false unless convert_payload!

    payload["state"] == "started"
  end

  def parse_project_status
    return unless convert_payload!

    status = ProjectStatus.new
    status.success = payload["result"].to_i == 0
    status.url = project.feed_url.gsub(".json", "/#{payload["id"]}")
    published_at = payload["finished_at"]
    status.build_id = payload["id"]
    status.published_at = Time.parse(published_at).localtime if published_at.present?
    status
  end

  def convert_payload!
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
