class TeamCityProject < Project
  FEED_URL_REGEXP = %r{https?://(.*)/guestAuth/cradiator\.html\?buildTypeId=(.*)$}

  validates :url, presence: true
  validates :build_id, presence: true

  def url
    feed_url =~ FEED_URL_REGEXP
    $1
  end

  def url=(url)
    self.feed_url = "http://#{url}/guestAuth/cradiator.html?buildTypeId=#{build_id}"
  end

  def build_id
    feed_url =~ FEED_URL_REGEXP
    $2
  end

  def build_id=(build_id)
    self.feed_url = "http://#{url}/guestAuth/cradiator.html?buildTypeId=#{build_id}"
  end

  def build_status_url
    feed_url
  end

  def self.feed_url_fields
    ["URL","Build ID"]
  end

  def processor
    LegacyTeamCityPayloadProcessor
  end
end
