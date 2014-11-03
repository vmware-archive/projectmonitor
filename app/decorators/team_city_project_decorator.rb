class TeamCityProjectDecorator < ProjectDecorator

  def current_build_url
    if object.webhooks_enabled?
      object.parsed_url
    else
      "#{object.ci_base_url}/viewType.html?buildTypeId=#{object.ci_build_name}"
    end
  end

end
