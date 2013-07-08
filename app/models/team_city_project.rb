class TeamCityProject < Project

  validates_presence_of :team_city_build_id, :team_city_base_url, unless: ->(project) { project.webhooks_enabled }
  validates :team_city_build_id, format: {with: /\Abt\d+\Z/, message: 'must begin with bt'}, unless: ->(project) { project.webhooks_enabled }

  def self.project_specific_attributes
    ['team_city_base_url', 'team_city_build_id']
  end

  def feed_url
    url_with_scheme "#{team_city_base_url}/guestAuth/cradiator.html?buildTypeId=#{team_city_build_id}"
  end

  def current_build_url
    if webhooks_enabled?
      parsed_url
    else
      "#{team_city_base_url}/viewType.html?buildTypeId=#{team_city_build_id}"
    end
  end

  def project_name
    feed_url
  end

  def fetch_payload
    LegacyTeamCityXmlPayload.new
  end

  def webhook_payload
    LegacyTeamCityXmlPayload.new
  end

  def build_status_url
    feed_url
  end

end
