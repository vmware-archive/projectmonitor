class SemaphorePayload < Payload
  def branch=(new_branch)
    @branch = new_branch unless new_branch.blank?
  end

  def branch
    @branch ||= 'master'
  end

  def building?
    status_content.first['result'] == 'pending'
  end

  def content_ready?(content)
    content['result'] != 'pending' &&
      specified_branch?(content)
  end

  def convert_content!(raw_content)
    extract_builds_if_build_history_url(convert_json_content!(raw_content))
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
    Time.parse(content['started_at']) if content['started_at']
  end

  private

  def extract_builds_if_build_history_url(result)
    result.first.key?("builds") ? result.first["builds"].first(15) : result
  end

  def specified_branch?(content)
    branch == content['branch_name']
  end
end
