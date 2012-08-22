class SemaphorePayload < Payload

  def building?
    false
  end

  def convert_content!(content)
    [JSON.parse(content)]
  rescue => e
    log_error(e)
    self.processable = self.build_processable = false
    []
  end

  def parse_success(content)
    content['result'] == 'passed'
  end

  def parse_url(content)
    self.parsed_url = content['build_url'].split('builds').first
    content['build_url']
  end

  def parse_build_id(content)
    content['build_number']
  end

  def parse_published_at(content)
    Time.parse(content['finished_at'])
  end

end
