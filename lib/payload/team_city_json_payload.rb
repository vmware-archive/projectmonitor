class TeamCityJsonPayload < Payload

  def building?
    status_content.first['buildResult'] == 'running' && status_content.first['notifyType'] == 'buildStarted'
  end

  private

  def convert_content!(content)
    [content['build']]
  end

  def parse_success(content)
    content['buildResult'] == 'success'
  end

  def parse_url(content)
  end

  def parse_build_id(content)
    content['buildId']
  end

  def parse_published_at(content)
    Time.now
  end

end
