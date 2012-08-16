class SemaphorePayload < Payload

  def convert_content!(content)
    [JSON.parse(content)]
  rescue JSON::ParserError
    self.processable = self.build_processable = false
    []
  end

  def parse_success(content)
    content['result'] == 'passed'
  end

  def parse_url(content)
    content['build_url']
  end

  def parse_build_id(content)
    content['build_number']
  end

  def parse_published_at(content)
    Time.parse(content['finished_at'])
  end

end
