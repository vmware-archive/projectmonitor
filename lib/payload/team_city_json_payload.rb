class TeamCityJsonPayload < Payload

  def building?
    status_content.first['buildResult'] == 'running' && status_content.first['notifyType'] == 'buildStarted'
  end

  def convert_content!(content)
    [JSON.parse(content)]
  rescue => e
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  def content_ready?(content)
    content['buildResult'] != 'running'
  end

  def parse_success(content)
    content['buildResult'] == 'success'
  end

  def parse_url(content)
    self.parsed_url = content['buildStatusUrl']
  end

  def parse_build_type_id(content)
    content['buildTypeId']
  end

  def parse_build_id(content)
    content['buildId']
  end

  def parse_published_at(content)
    Time.now
  end

end
