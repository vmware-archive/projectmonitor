class TddiumPayload < Payload

  def initialize(project_name)
    super()
    @project_name = project_name
  end

  def building?
    @build_status_content.first.attributes['activity'].value == 'Building'
  end

  def content_ready?(content)
    content.attributes['activity'].value != 'Building'
  end

  def convert_content!(content)
    if content.present?
      parsed = Nokogiri::XML.parse(content)
      raise ArgumentError("Invalid XML") unless parsed.errors.count == 0
      # We need to explicitly cast to array because Nokogiri will insert nil entries when you do first(n). This will cause the application to die horribly.
      parsed.css("Project[name=\"#{@project_name}\"]").to_a
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
    content.attributes['lastBuildStatus'].value == 'Success'
  end

  def parse_url(content)
    content.attributes['webUrl'].value
  end

  def parse_build_id(content)
    content.attributes['lastBuildLabel'].value
  end

  def parse_published_at(content)
   Time.parse(content.attributes['lastBuildTime'].value)
  end

end
