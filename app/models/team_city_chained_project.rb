class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def payload
    TeamCityChainedPayload
  end

  def payload_fetch_format
    :xml
  end

  private

  def self.project_attribute_prefix
    'team_city_rest'
  end
end
