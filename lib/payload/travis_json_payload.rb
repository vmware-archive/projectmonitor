class TravisJsonPayload < Payload
  def building?
    status_content.first['state'] == "started"
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def convert_webhook_content!(content)
    convert_content!(Rack::Utils.parse_nested_query(content)['payload'] || '')
  end

  def convert_content!(content)
    parsed_content = JSON.parse(content) || {}
    Array.wrap(parsed_content)
  rescue => e
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  def parse_success(content)
    return if content['state'] == 'started'
    content['result'].to_i == 0
  end

  def parse_url(content)
    self.parsed_url = "https://api.travis-ci.org/builds/#{content['id']}"
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['finished_at']
    Time.parse(published_at) if published_at.present?
  end
end
