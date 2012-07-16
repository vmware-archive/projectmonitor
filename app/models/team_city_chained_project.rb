class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren
  def processor
    TeamCityChainedPayloadProcessor
  end
end
