class TravisJsonPayload < Payload
  def building?
    status_content.first['state'] == 'started'
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def convert_webhook_content!(content)
    convert_content!(Rack::Utils.parse_nested_query(content)['payload'] || '')
  end

  def convert_content!(content)
    Array.wrap(JSON.parse(content))
  rescue => e
    error_text << e.message
    self.processable = self.build_processable = false
    []
  end

  def parse_success(content)
    return if content['state'] == 'started'
    content['result'].to_i == 0
  end

  def parse_url(content)
    parsed_url = content['build_url']
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['finished_at']
    Time.parse(published_at).localtime if published_at.present?
  end
end
