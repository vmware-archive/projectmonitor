class TeamCityRestProject < Project

  attr_accessible :team_city_rest_base_url, :team_city_rest_build_type_id
  validates :team_city_rest_base_url, presence: true
  validates :team_city_rest_build_type_id, presence: true, format: {with: /\Abt\d+\Z/, message: 'must begin with bt'}

  def build_status_url
    feed_url
  end

  def feed_url
    "http://#{team_city_rest_base_url}/app/rest/builds?locator=running:all,buildType:(id:#{team_city_rest_build_type_id})"
  end

  def status_url
    "http://#{team_city_rest_base_url}/viewType.html?tab=buildTypeStatusDiv&buildTypeId=#{team_city_rest_build_type_id}"
  end

  def project_name
    feed_url
  end

  def fetch_payload
    TeamCityXmlPayload.new
  end

  def webhook_payload
    TeamCityJsonPayload.new
  end

end
