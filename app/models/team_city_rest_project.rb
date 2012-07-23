class TeamCityRestProject < Project

  attr_accessible :team_city_rest_base_url, :team_city_rest_build_type_id
  validates :team_city_rest_base_url, presence: true
  validates :team_city_rest_build_type_id, presence: true, format: {with: /\Abt\d+\Z/, message: 'must begin with bt'}

  def self.feed_url_fields
    ["Teamcity Rest Base URL", "Teamcity Rest Build Type ID"]
  end

  def build_status_url
    feed_url
  end

  def feed_url
    "http://#{team_city_rest_base_url}/app/rest/builds?locator=running:all,buildType:(id:#{team_city_rest_build_type_id})"
  end

  def project_name
    feed_url
  end

  def processor
    TeamCityPayloadProcessor
  end
end
