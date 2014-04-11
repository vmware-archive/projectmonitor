class TeamCityRestProjectDecorator < ProjectDecorator

  def current_build_url
    url = if object.webhooks_enabled?
      object.parsed_url
    else
      "#{object.team_city_rest_base_url}/viewType.html?tab=buildTypeStatusDiv&buildTypeId=#{object.team_city_rest_build_type_id}"
    end

    object.send(:url_with_scheme, url)
  end

end
