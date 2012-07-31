class TeamCityChainedProject < TeamCityRestProject

  def has_dependencies?
    true
  end

  def dependent_build_info_url
    "http://#{team_city_rest_base_url}/httpAuth/app/rest/buildTypes/id:#{team_city_rest_build_type_id}"
  end

  private

  def self.project_attribute_prefix
    'team_city_rest'
  end

end
