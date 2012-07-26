class TeamCityXmlPayload < Payload
  def building?
    status_content.first.attribute('running').present?
  end

  def build_status_is_processable?
    status_is_processable?
  end

  private

  def convert_content!(content)
    Nokogiri::XML.parse(content).css('build').to_a
  end

  def parse_success(content)
    return if content.attribute('running').present? && content.attribute('status').value != 'FAILURE'
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
