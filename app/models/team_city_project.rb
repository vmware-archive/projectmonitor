class TeamCityProject < Project

  validates_format_of :feed_url, :with => /http:\/\/.*\/guestAuth\/cradiator.html\?buildTypeId=.*$/

  def build_status_url
    feed_url
  end

  def building_parser(content)
    building_parser = StatusParser.new
    document = Nokogiri::XML.parse(content)
    p_element = document.css("Build")
    return building_parser if p_element.empty?
    building_parser.building = p_element.attribute('activity').value == 'Building'
    building_parser
  end

  def status_parser(content)
    status_parser = StatusParser.new
    begin
      latest_build = Nokogiri::XML.parse(content).css('Build').first
      status_parser.success = latest_build.attribute('lastBuildStatus').value == "NORMAL"
      status_parser.url = latest_build.attribute('webUrl').value
      pub_date = Time.parse(latest_build.attribute('lastBuildTime').value)
      status_parser.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    rescue
    end
    status_parser
  end
end
