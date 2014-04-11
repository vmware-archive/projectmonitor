class TeamCityProjectDecorator < ProjectDecorator

  def current_build_url
    if object.webhooks_enabled?
      object.parsed_url
    else
      "#{object.team_city_base_url}/viewType.html?buildTypeId=#{object.team_city_build_id}"
    end
  end

end
