class TravisJsonPayload < Payload
  def building?
    status_content.first['last_build_status'].to_i != 0
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
    content['last_build_result'].to_i == 0
  end

  def parse_url(content)
    self.parsed_url = "https://travis-ci.org/#{content['slug']}"
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['last_build_finished_at']
    Time.parse(published_at).localtime if published_at.present?
  end
end
