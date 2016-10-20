class ConcoursePayload < Payload

  def initialize(build_url_base)
    super()
    @build_url_base = build_url_base
  end

  def building?
    !content_ready?(@build_status_content.first)
  end

  def content_ready?(content)
    content['status'] != 'started'
  end

  def convert_content!(raw_content)
    convert_json_content!(raw_content)
  end

  alias_method :convert_build_content!, :convert_content!

  def convert_webhook_content!(content)
    raise NotImplementedError
  end

  def parse_success(content)
    content['status'] == 'succeeded'
  end

  def parse_url(content)
    "#{@build_url_base}/#{parse_build_id(content)}"
  end

  def parse_build_id(content)
    content['name']
  end

  def parse_published_at(content)
    Time.at(content['start_time'])
  end
end
