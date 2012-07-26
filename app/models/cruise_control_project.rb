class CruiseControlProject < Project

  attr_accessible :cruise_control_rss_feed_url
  validates :cruise_control_rss_feed_url, presence: true, format: {with: /\Ahttps?:\/\/.*\.rss\Z/i, message: 'should end with ".rss"'}

  def feed_url
    cruise_control_rss_feed_url
  end

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    ["#{url_components.scheme}://#{url_components.host}"].tap do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/XmlStatusReport.aspx"
    end.join
  end

  def fetch_payload
    CruiseControlXmlPayload.new(self)
  end

  def webhook_payload
    CruiseControlXmlPayload.new(self)
  end
end
