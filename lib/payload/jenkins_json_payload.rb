class JenkinsJsonPayload < Payload
  def building?
    status_content.first['build']['phase'] == 'STARTED'
  end

  def convert_content!(content)
    [JSON.parse(Rack::Utils.parse_nested_query(content)['payload'])]
  rescue JSON::ParserError
    self.processable = self.build_processable = false
    []
  end

  def parse_success(content)
    content['build']['phase'] == 'SUCCESS'
  end

  def parse_url(content)
    content['build']['url']
  end

  def parse_build_id(content)
    content['build']['number']
  end

  def parse_published_at(content)
    Time.now
  end
end
