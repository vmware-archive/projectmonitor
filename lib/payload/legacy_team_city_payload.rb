class LegacyTeamCityPayload < Payload
  def building?
    p_element = @build_status_content
    return false if p_element.empty?
    p_element.attribute('activity').value == 'Building'
  end

  def success
    return if @content.attribute('activity').value == 'Building'
    @content.attribute('lastBuildStatus').value == "NORMAL"
  end

  def url
    @content.attribute('webUrl').value
  end

  def build_id
    @content.attribute('lastBuildLabel').value
  end

  def published_at
    pub_date = Time.parse(@content.attribute('lastBuildTime').value)
    (pub_date == Time.at(0) ? Time.now : pub_date).localtime
  end

  private

  def convert_content!
    @status_content = Nokogiri::XML.parse(status_content).css('Build').to_a.first(50)
  end

  def convert_build_content!
    @build_status_content = Nokogiri::XML.parse(build_status_content).css('Build')
  end

end
