class CruiseControlProject < Project

  validates :cruise_control_rss_feed_url, presence: true, format: {with: /\Ahttps?:\/\/.*\.rss\Z/i, message: 'should end with ".rss"'}, unless: ->(project) { project.webhooks_enabled }

  alias_attribute :feed_url, :cruise_control_rss_feed_url

  def self.project_specific_attributes
    ['cruise_control_rss_feed_url']
  end

  def project_name
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0] if feed_url.present?
  end

  def build_status_url
    return if feed_url.nil?

    url_components = URI.parse(feed_url)
    "#{url_components.scheme}://#{url_components.host}:#{url_components.port}/XmlStatusReport.aspx"
  end

  def fetch_payload
    CruiseControlXmlPayload.new(name)
  end

end
