class TeamCityRestProjectDecorator < ProjectDecorator

  def current_build_url
    url = if object.webhooks_enabled?
      object.parsed_url
    else
      "#{object.ci_base_url}/viewType.html?tab=buildTypeStatusDiv&buildTypeId=#{object.ci_build_name}"
    end

    object.url_with_scheme(url)
  end

end
