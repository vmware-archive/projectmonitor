class TeamCityRestProject < Project
  # http://teamcity:8111/app/rest/builds?locator=running:all,buildType:(id:bt2)
  validates_format_of :feed_url, :with => /http:\/\/.*\/app\/rest\/builds\?locator=running:all,buildType:\(id:bt\d*\)$/

  def build_status_url
    feed_url
  end

  def parse_building_status(content)
    status = super(content)
    document = Nokogiri::XML.parse(content)
    p_element = document.css("build").first
    return status if p_element.nil? || p_element.attribute('running').nil?
    status.building = p_element.attribute('running').value == 'true'
    status
  end

  def parse_project_status(content)
    status = super(content)
    begin
      latest_build = Nokogiri::XML.parse(content).css('build').first
      status.success = latest_build.attribute('status').value == "SUCCESS"
      status.url = latest_build.attribute('webUrl').value

#      TeamCity REST API does not currently report build time. See: http://youtrack.jetbrains.net/issue/TW-14902
#      pub_date = Time.parse(latest_build.attribute('startDate').value)
#      status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
      status.published_at = Clock.now.localtime
    rescue
    end
    status
  end
end
