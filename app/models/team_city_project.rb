class TeamCityProject < Project

  attr_accessible :team_city_base_url, :team_city_build_id
  validates :team_city_base_url, presence: true
  validates :team_city_build_id, presence: true, format: {with: /\Abt\d+\Z/, message: 'must begin with bt'}

  def self.project_specific_attributes
    ['team_city_base_url', 'team_city_build_id']
  end

  def feed_url
    "http://#{team_city_base_url}/guestAuth/cradiator.html?buildTypeId=#{team_city_build_id}"
  end

  def build_status_url
    feed_url
  end

  def project_name
    feed_url
  end

  def payload
    LegacyTeamCityPayload
  end

  def payload_fetch_format
    :xml
  end
end
