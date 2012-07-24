class TeamCityChainedPayload < TeamCityPayload; end

class TeamCityChainedXmlPayload < TeamCityXmlPayload
  def building?
    super || project.children.any?(&:building?)
  end

  def success
    return false if project.children.any?(&:red?)
    super
  end

  def published_at
    [super, *project.children.map(&:last_build_time)].max
  end
end
