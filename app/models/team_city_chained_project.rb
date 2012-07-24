class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def processor
    TeamCityChainedPayloadProcessor
  end

private

  def self.project_attribute_prefix
    'team_city_rest'
  end

end
