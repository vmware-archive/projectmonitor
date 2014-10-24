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

  def convert_content!(content)
    if content.present?
      JSON.parse(content)
    else
      log_error("No content supplied")
      self.processable = false
      []
    end
  rescue => e
    self.processable = self.build_processable = false
    raise Payload::InvalidContentException, e.message
  end

  def convert_build_content!(content)
    convert_content!(content)
  end

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
    nil
  end
end
