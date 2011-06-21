class TeamCityRestProject < Project
  URL_FORMAT = /http:\/\/.*\/app\/rest\/builds\?locator=running:all,buildType:\(id:bt\d*\)(,user:(\w+))?(,personal:(true|false|any))?$/
  URL_MESSAGE = "should look like ('[...]' is optional): http://*/app/rest/builds?locator=running:all,buildType:(id:bt*)[,user:*][,personal:true|false|any]"

  validates_format_of :feed_url, :with => URL_FORMAT, :message => URL_MESSAGE

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

      pub_date = Clock.now
      pub_date = Time.parse(latest_build.attribute('startDate').value) if latest_build.attribute('startDate').present?
      status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    rescue
    end
    status
  end
end
