class TeamCityProject < Project

  attr_accessible :team_city_base_url, :team_city_build_id
  validates :team_city_base_url, presence: true
  validates :team_city_build_id, presence: true, format: {with: /\Abt\d+\Z/, message: 'must begin with bt'}

  def self.feed_url_fields
    ["Teamcity Base URL","Teamcity Build ID"]
  end

  def feed_url
    "http://#{team_city_base_url}/guestAuth/cradiator.html?buildTypeId=#{team_city_build_id}"
  end

  def build_status_url
    feed_url
  end

  def processor
    LegacyTeamCityPayloadProcessor
  end

  def project_name
    feed_url
  end
end
