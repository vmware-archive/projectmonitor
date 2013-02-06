class LegacyTeamCityXmlPayload < Payload
  def building?
    p_element = build_status_content
    return false if p_element.empty?
    p_element.attribute('activity').value == 'Building'
  end

  private

  def content_ready?(content)
    content.attribute('activity').value != 'Building'
  end

  def convert_content!(content)
    parsed_content = Nokogiri::XML.parse(content)
    raise Payload::InvalidContentException, "Error converting content" unless parsed_content.root
    parsed_content.css('Build').to_a
  end

  def convert_build_content!(content)
    parsed_content = Nokogiri::XML.parse(content)
    raise Payload::InvalidContentException, "Error converting content for project #{@project_name}" unless parsed_content.root
    parsed_content.css('Build')
  end

  def parse_success(content)
    content.attribute('lastBuildStatus').value == 'NORMAL'
  end

  def parse_url(content)
    content.attribute('webUrl').value
  end

  def parse_build_id(content)
    content.attribute('lastBuildLabel').value
  end

  def parse_published_at(content)
    pub_date = Time.parse(content.attribute('lastBuildTime').value)
    (pub_date == Time.at(0) ? Time.now : pub_date).localtime
  end
end
