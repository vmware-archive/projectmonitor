class TeamCityProject < Project

  validates_format_of :feed_url, :with => /https?:\/\/.*\/guestAuth\/cradiator.html\?buildTypeId=.*$/,
    :message => "should look like: http://*/guestAuth/cradiator.html?buildTypeId=*"

  def build_status_url
    feed_url
  end

  def self.feed_url_fields
    ["URL","ID"]
  end

  def self.build_url_from_fields(params)
    "http://#{params["URL"]}/guestAuth/cradiator.html?buildTypeId=#{params["ID"]}"
  end

  def processor
    LegacyTeamCityPayloadProcessor
  end
end
