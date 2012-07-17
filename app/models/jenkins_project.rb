class JenkinsProject < Project
  FEED_URL_REGEXP = %r{(https?://.*)/job/(.*)/rssAll$}

  validates :url, :build_name, presence: true

  attr_accessible :url, :build_name

  def url
    feed_url =~ FEED_URL_REGEXP
    $1
  end

  def url=(url)
    self.feed_url = "#{url}/job/#{build_name}/rssAll"
  end

  def build_name
    feed_url =~ FEED_URL_REGEXP
    $2
  end

  def build_name=(build_name)
    self.feed_url = "#{url}/job/#{build_name}/rssAll"
  end

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*job\/(.*)/i)[0][0].split('/').first
  end

  def self.feed_url_fields
    ["URL","Build Name"]
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
