class TravisJsonPayload < Payload
  def building?
    status_content.first['state'] == 'started'
  end

  def build_status_is_processable?
    status_is_processable?
  end

  private

  def unwrap_webhook_content(content)
    content['payload']
  end

  def unwrap_polled_content(content)
    content
  end

  def convert_content!(content)
    status_content = if content.respond_to?(:key?) && content.key?('payload')
                       unwrap_webhook_content(content)
                     else
                       unwrap_polled_content(content)
                     end
    Array.wrap(JSON.parse(status_content))

  rescue JSON::ParserError
    self.processable = false
    []
  end

  def parse_success(content)
    return if content['state'] == 'started'
    content['result'].to_i == 0
  end

  def parse_url(content)
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['finished_at']
    Time.parse(published_at).localtime if published_at.present?
  end
end
