class TravisJsonPayload < Payload
  attr_accessor :slug

  def branch=(new_branch)
    @branch = new_branch unless new_branch.blank?
  end

  def branch
    @branch ||= 'master'
  end

  def building?
    status_content.first['started_at'].present? && status_content.first['finished_at'].nil?
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def content_ready?(content)
    content['finished_at'].present? &&
      content['state'] != 'started' &&
      content['state'] != 'created' &&
      specified_branch?(content) &&
      content['event_type'] != 'pull_request'
  end

  def convert_webhook_content!(content)
    decoded_payload = extract_payload_from(content)
    convert_content!(decoded_payload)
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['started_at']
    Time.parse(published_at) if published_at.present?
  end

  def parse_success(content)
    content['result'] && content['result'].to_i == 0
  end

  def parse_url(content)
    if @slug
      self.parsed_url = "https://travis-ci.org/#{@slug}/builds/#{content['id']}"
    else
      self.parsed_url = "https://api.travis-ci.org/builds/#{content['id']}"
    end
  end

  private

  def specified_branch?(content)
    branch == content['branch']
  end

  def extract_payload_from(content)
    nested_content = Rack::Utils.parse_nested_query(content)
    payload = nested_content['payload']
    URI.decode(payload)
  rescue => e
    handle_processing_exception(e)
  end

  def convert_content!(content)
    parsed_content = JSON.parse(content)
    Array.wrap(parsed_content)
  rescue => e
    handle_processing_exception(e)
  end

  def handle_processing_exception(e)
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end
end
