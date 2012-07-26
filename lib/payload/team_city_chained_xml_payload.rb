require "#{Rails.root}/lib/payload/team_city_xml_payload"

class TeamCityChainedXmlPayload < TeamCityXmlPayload
  def building?
    super || project.children.any?(&:building?)
  end

  private

  def parse_success(content)
    return false if project.children.any?(&:red?)
    super
  end

  def parse_published_at(content)
    [super, *project.children.map(&:last_build_time)].max
  end
end
