class LegacyTeamCityPayloadProcessor < ProjectPayloadProcessor
  def parse_building_status
    building_status = BuildingStatus.new(false)
    document = Nokogiri::XML.parse(payload)
    p_element = document.css("Build")
    return building_status if p_element.empty?
    building_status.building = p_element.attribute('activity').value == 'Building'
    building_status
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)
    latest_build = Nokogiri::XML.parse(payload).css('Build').first
    if latest_build
      status.success = latest_build.attribute('lastBuildStatus').value == "NORMAL"
      status.url = latest_build.attribute('webUrl').value
      pub_date = Time.parse(latest_build.attribute('lastBuildTime').value)
      status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    end
    status
  end
end
