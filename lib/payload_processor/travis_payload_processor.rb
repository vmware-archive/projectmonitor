class TravisPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    building_status = BuildingStatus.new(false)
    if payload && building_payload = payload.last
      project_html = Nokogiri::XML.parse(building_payload).css('Project').first
      building_status.building = project_html.attribute("activity").value == "Building" if project_html
    end
    building_status
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)
    if payload && project_payload = payload.first
      if project_html = Nokogiri::XML.parse(project_payload).css('Project').first
        status.success = project_html.attribute("lastBuildStatus").value == "Success"
        status.url = project_html.attribute("webUrl").value
        published_at = project_html.attribute("lastBuildTime").value
        status.published_at = Time.parse(published_at).localtime if published_at.present?
      end
    end
    status
  end
end
