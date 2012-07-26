class TeamCityChainedProject < TeamCityRestProject
  include TeamCityProjectWithChildren

  def fetch_payload
    TeamCityChainedXmlPayload.new(self)
  end

  def webhook_payload
    TeamCityChainedXmlPayload.new(self)
  end

  private

  def self.project_attribute_prefix
    'team_city_rest'
  end
end
