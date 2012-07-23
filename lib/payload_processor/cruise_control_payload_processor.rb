class CruiseControlPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    return false unless building_payload = payload.last

    document = Nokogiri::XML(building_payload.downcase)
    project_element = document.at_xpath("/projects/project[@name='#{project.project_name.downcase}']")
    project_element && project_element['activity'] == "building"
  end

  def parse_project_status
    return unless project_payload = payload.first

    status = ProjectStatus.new
    document = Nokogiri::XML(project_payload.downcase)
    status.success = !!(document.css('title').to_s =~ /success/)
    if (pub_date = document.css('pubdate')).present?
      pub_date = Time.parse(pub_date.text)
      status.published_at = (pub_date == Time.at(0) ? Time.now : pub_date).localtime
    end
    if url = document.css('item/link')
      status.url = url.text
    end
    status
  end
end
