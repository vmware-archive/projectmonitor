class TeamCityRestProject < Project

  URL_FORMAT = %r{http://(.*)/app/rest/builds\?locator=running:all,buildType:\(id:(bt\d*)\)}
  URL_MESSAGE = "should look like ('[...]' is optional): http://*/app/rest/builds?locator=running:all,buildType:(id:bt*)[,user:*][,personal:true|false|any]"

  validates_format_of :feed_url, :with => URL_FORMAT, :message => URL_MESSAGE

  def build_status_url
    feed_url
  end

  def self.feed_url_fields
    ["URL","Build Type ID"]
  end

  def url
    feed_url =~ URL_FORMAT
    $1
  end

  def url=(url)
    self.feed_url = "http://#{url}/app/rest/builds?locator=running:all,buildType:(id:#{build_type_id})"
  end

  def build_type_id
    feed_url =~ URL_FORMAT
    $2
  end

  def build_type_id=(build_type_id)
    self.feed_url = "http://#{url}/app/rest/builds?locator=running:all,buildType:(id:#{build_type_id})"
  end

  def processor
    TeamCityPayloadProcessor
  end
end
