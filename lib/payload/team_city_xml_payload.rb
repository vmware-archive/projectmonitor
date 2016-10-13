class TeamCityXmlPayload < Payload

  def initialize(project)
    super()
    @project = project
  end

  def building?
    status_content.first.attribute('running').present?
  end

  def build_status_is_parseable?
    status_is_parseable?
  end

  private

  def content_ready?(content)
    return false if content.attribute('running').present? && content.attribute('status').value != 'FAILURE'
    return false if content.attribute('status').value == 'UNKNOWN'
    true
  end

  def convert_content!(raw_content)
    Array.wrap(convert_xml_content!(raw_content, true).css('build'))
  end

  def parse_success(content)
    content.attribute('status').value == 'SUCCESS'
  end

  def parse_url(content)
    content.attribute('webUrl').value
  end

  def parse_build_id(content)
    content.attribute('id').value
  end

  def parse_published_at(content)
    parse_start_date_attribute(content.attribute('startDate'))
  end

  def parse_start_date_attribute(start_date_attribute)
    if start_date_attribute.present?
      Time.parse(start_date_attribute.value).localtime
    else
      Time.now.localtime
    end
  end
end
