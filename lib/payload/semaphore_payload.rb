class SemaphorePayload < Payload
  def building?
    status_content.first['result'] == 'pending'
  end

  def convert_content!(content)
    json = JSON.parse(content)
    json = extract_builds_if_build_history_url(json)
    Array.wrap(json)
  rescue => e
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  def parse_success(content)
    content['result'] == 'pending' ? nil : content['result'] == 'passed'
  end

  def parse_url(content)
    self.parsed_url = content['build_url'].split('builds').first
    content['build_url']
  end

  def parse_build_id(content)
    content['build_number']
  end

  def parse_published_at(content)
    Time.parse(content['finished_at']) if content['finished_at']
  end


  private

  def extract_builds_if_build_history_url(json)
    if json.key? "builds"
      json["builds"].first(15)
    else
      json
    end
  end

end
