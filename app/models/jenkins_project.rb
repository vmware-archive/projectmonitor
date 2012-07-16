class JenkinsProject < Project
  validates_format_of :feed_url, :with =>  /https?:\/\/.*job\/.*\/rssAll$/, :message => "should look like: http://*job/*/rssAll"

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*job\/(.*)/i)[0][0].split('/').first
  end

  def self.feed_url_fields
    ["URL","Build Name"]
  end

  def self.build_url_from_fields(params)
    params["URL"] + '/job/' + params["Build Name"] + '/rssAll'
  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    ["#{url_components.scheme}://#{url_components.host}"].tap do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/cc.xml"
    end.join
  end

  def processor
    JenkinsPayloadProcessor
  end
end
