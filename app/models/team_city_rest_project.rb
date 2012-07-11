class TeamCityRestProject < Project
  include TeamCityBuildStatusParsing

  URL_FORMAT = /http:\/\/.*\/app\/rest\/builds\?locator=running:all,buildType:\(id:bt\d*\)(,user:(\w+))?(,personal:(true|false|any))?$/
  URL_MESSAGE = "should look like ('[...]' is optional): http://*/app/rest/builds?locator=running:all,buildType:(id:bt*)[,user:*][,personal:true|false|any]"

  validates_format_of :feed_url, :with => URL_FORMAT, :message => URL_MESSAGE

  def build_status_url
    feed_url
  end

  def parse_building_status(content)
    raise NotImplementedError, "TeamCityRestProject#parse_building_status is no longer used"
  end

  def parse_project_status(content)
    raise NotImplementedError, "TeamCityRestProject#parse_project_status is no longer used"
  end

  def fetch_new_statuses
    build_live_statuses.each do |parsed_status|
      parsed_status.save! unless statuses.find_by_url(parsed_status.url)
    end
  end

  def fetch_building_status
    live_building_status
  end

  def build_id
    feed_url.match(/id:([^)]*)/)[1]
  end

  def self.feed_url_fields
    ["URL","ID"]
  end

  def self.build_url_from_fields(params)
    "http://#{params["URL"]}/app/rest/builds?locator=running:all,buildType:(id:#{params["ID"]})"
  end

  protected

  def build_live_statuses
    live_status_hashes.map { |status_hash|
      ProjectStatus.new(
        :project => self,
        :online => true,
        :success => status_hash[:status] == 'SUCCESS',
        :url => status_hash[:url],
        :published_at => status_hash[:published_at],
      )
    }.sort { |status1, status2| status1.published_at <=> status2.published_at }
  end
end
