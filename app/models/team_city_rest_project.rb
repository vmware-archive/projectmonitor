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

    if p_element.present? && p_element.attribute('running').present?
      status.building = true
    end

    status
  end

  def parse_project_status(content)
    raise NotImplementedError, "TeamCityRestProject#parse_project_status is no longer used"
  end

  def process_status_update
    xml_text = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
    parse_project_statuses(xml_text).each do |parsed_status|
      parsed_status.save! unless statuses.find_by_url(parsed_status.url)
    end
  rescue Net::HTTPError => e
    error = "HTTP Error retrieving status for project '##{id}': #{e.message}"
    statuses.create(:error => error) unless status.error == error
  end

  def parse_project_statuses(content)
    Nokogiri::XML.parse(content).css('build').first(50).compact.
      reject { |status_elem|
        status_elem.attribute('running') && status_elem.attribute('status').value == "SUCCESS"
      }.
      map { |status_elem|
        status = ProjectStatus.new(:project => self, :online => true)
        status.success = status_elem.attribute('status').value == "SUCCESS"
        status.url = status_elem.attribute('webUrl').value

        status.published_at = if status_elem.attribute('startDate').present?
                                Time.parse(status_elem.attribute('startDate').value).localtime
                              else
                                Clock.now.localtime
                              end
        status
      }
  end

  def build_id
    feed_url.match(/id:([^)]*)/)[1]
  end

  private
  def build_type_url
    uri = URI(feed_url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/httpAuth/app/rest/buildTypes/id:#{build_id}"
  end
end
