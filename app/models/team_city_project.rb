class TeamCityProject < Project

  validates_format_of :feed_url, :with => /http:\/\/.*\/guestAuth\/cradiator.html\?buildTypeId=.*$/

  def build_status_url
    feed_url
  end

  def parse_building_status(content)
    status = super(content)
    document = Nokogiri::XML.parse(content)
    p_element = document.css("Build")
    return status if p_element.empty?
    status.building = p_element.attribute('activity').value == 'Building'
    status
  end

  def parse_project_status(content)
    status = super(content)
    begin
      latest_build = Nokogiri::XML.parse(content).css('Build').first
      status.success = latest_build.attribute('lastBuildStatus').value == "NORMAL"
      status.url = latest_build.attribute('webUrl').value
      pub_date = Time.parse(latest_build.attribute('lastBuildTime').value)
      status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    rescue
    end
    status
  end
end
