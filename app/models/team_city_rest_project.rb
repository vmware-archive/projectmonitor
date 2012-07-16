class TeamCityRestProject < Project

  URL_FORMAT = /http:\/\/.*\/app\/rest\/builds\?locator=running:all,buildType:\(id:bt\d*\)(,user:(\w+))?(,personal:(true|false|any))?$/
  URL_MESSAGE = "should look like ('[...]' is optional): http://*/app/rest/builds?locator=running:all,buildType:(id:bt*)[,user:*][,personal:true|false|any]"

  validates_format_of :feed_url, :with => URL_FORMAT, :message => URL_MESSAGE

  def build_status_url
    feed_url
  end

  def build_id
    feed_url.match(/id:([^)]*)/)[1]
  end

  def self.feed_url_fields
    ["URL","ID"]
  end

  def self.build_url_from_fields(params)
    "http://#{params["URL"]}/app/rest/builds?locator=running:all,buildType:(id:#{params["ID"]})"
  end

  def processor
    TeamCityPayloadProcessor
  end
end
