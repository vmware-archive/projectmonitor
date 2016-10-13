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

  def convert_content!(raw_content)
    if raw_content.present?
      # We need to explicitly cast to array because Nokogiri will insert nil entries when you do first(n). This will cause the application to die horribly.
      convert_xml_content!(raw_content, true).css("Project[name=\"#{@project_name}\"]").to_a
    else
      log_error("No content supplied")
      self.parsed_successfully = false
      []
    end
  end

  alias_method :convert_build_content!, :convert_content!

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
