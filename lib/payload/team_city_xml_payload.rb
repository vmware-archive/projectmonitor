class TeamCityXmlPayload < Payload
  def building?
    status_content.first.attribute('running').present?
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def each_child(project)
    return unless has_dependent_content?

    selector = XPath.descendant(:'snapshot-dependency').to_s
    child_build_ids = Nokogiri::XML(dependent_content).xpath(selector).collect {|d| d.attributes['id'].value }
    child_build_ids.each do |child_id|
      child_project = project.clone
      child_project.team_city_rest_build_type_id = child_id
      yield child_project
    end
  end

  private

  def convert_content!(content)
    Nokogiri::XML.parse(content).css('build').to_a
  end

  def parse_success(content)
    return if content.attribute('running').present? && content.attribute('status').value != 'FAILURE'
    return if content.attribute('status').value == 'UNKNOWN'
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
