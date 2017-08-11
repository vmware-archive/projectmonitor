class CircleCiPayload < Payload
  def branch=(new_branch)
    @branch = new_branch unless new_branch.blank?
  end

  def branch
    @branch ||= 'master'
  end

  def building?
    status_content.first['status'] == 'running' || status_content.first['status'] == 'queued'
  end

  def content_ready?(content)
    content['status'] != 'running' &&
      content['status'] != 'queued' &&
      content['outcome'].present? &&
      specified_branch?(content)
  end

  def convert_content!(raw_content)
    convert_json_content!(raw_content)
  end

  def convert_webhook_content!(params)
    Array.wrap(params['payload'])
  end

  def parse_success(content)
    content['outcome'] == 'success'
  end

  def parse_url(content)
    self.parsed_url = content['build_url'].split('builds').first
    content['build_url']
  end

  def parse_build_id(content)
    content['build_num']
  end

  def parse_published_at(content)
    if content['start_time']
      Time.parse(content['start_time'])
    else
      Time.now
    end
  end

  private

  def specified_branch?(content)
    branch == content['branch'] || branch == '*'
  end
end
