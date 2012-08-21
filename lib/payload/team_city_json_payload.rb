class TeamCityJsonPayload < Payload

  def building?
    status_content.first['buildResult'] == 'running' && status_content.first['notifyType'] == 'buildStarted'
  end

  def convert_content!(content)
    [Rack::Utils.parse_nested_query(content)['build']].compact
  rescue => e
    log_error(e)
    self.processable = self.build_processable = false
    []
  end

  def parse_success(content)
    content['buildResult'] == 'success'
  end

  def parse_url(content)
    #TODO
  end

  def parse_build_id(content)
    content['buildId']
  end

  def parse_published_at(content)
    Time.now
  end

end
