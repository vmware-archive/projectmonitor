class CruiseControlProject < Project

  validates :cruise_control_rss_feed_url, presence: true, format: {with: /\Ahttps?:\/\/.*\.rss\Z/i, message: 'should end with ".rss"'}, unless: ->(project) { project.webhooks_enabled }

  def feed_url
    cruise_control_rss_feed_url
  end

  def project_name
    return if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def build_status_url
    return if feed_url.nil?

    url_components = URI.parse(feed_url)
    "#{url_components.scheme}://#{url_components.host}:#{url_components.port}/XmlStatusReport.aspx"
  end

  def fetch_payload
    CruiseControlXmlPayload.new(name)
  end

  def webhook_payload
    CruiseControlXmlPayload.new(name)
  end
end
