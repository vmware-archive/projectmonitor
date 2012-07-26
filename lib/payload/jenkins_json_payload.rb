class JenkinsJsonPayload < Payload
  def building?
    status_content.first["build"]["phase"] == "STARTED"
  end

  private

  def convert_content!(content)
    [Array.wrap(JSON.parse(content.keys.first)).first]
  rescue JSON::ParserError
    self.processable = false
    self.build_processable = false
    []
  end

  def parse_success(content)
    # TODO: find actual return code for success
    content["build"]["phase"] == "SUCCESS"
  end

  def parse_url(content)
    content["build"]["url"]
  end

  def parse_build_id(content)
    content["build"]["number"]
  end

  def parse_published_at(content)
    Time.now
  end
end
