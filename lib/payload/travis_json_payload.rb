class TravisJsonPayload < Payload
  attr_accessor :slug

  def branch=(new_branch)
    @branch = new_branch
  end

  def branch
    @branch ||= 'master'
  end

  def building?
    status_content.first['state'] == "started"
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def convert_webhook_content!(content)
    convert_content!(Rack::Utils.parse_nested_query(content)['payload'] || '')
  end

  def convert_content!(content)
    parsed_content = JSON.parse(content) || {}
    Array.wrap(parsed_content)
  rescue => e
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  def parse_success(content)
    return if content['state'] == 'started' || !specified_branch?(content)
    content['result'].to_i == 0
  end

  def parse_url(content)
    if @slug
      self.parsed_url = "https://travis-ci.org/#{@slug}/builds/#{content['id']}"
    else
      self.parsed_url = "https://api.travis-ci.org/builds/#{content['id']}"
    end
  end

  def parse_build_id(content)
    content['id']
  end

  def parse_published_at(content)
    published_at = content['finished_at']
    Time.parse(published_at) if published_at.present?
  end

  private

  def specified_branch?(content)
    branch == content['branch']
  end
end
