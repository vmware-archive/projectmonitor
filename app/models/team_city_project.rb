class TeamCityProject < Project

  validates_format_of :feed_url, :with => /http:\/\/.*\/guestAuth\/cradiator.html\?buildTypeId=.*$/

  def build_status_url
    feed_url
  end

  def building_parser(content)
    TeamCityStatusParser.building(content, self)
  end

  def status_parser(content)
    TeamCityStatusParser.status(content)
  end
end
