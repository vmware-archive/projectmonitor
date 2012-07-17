class CruiseControlProject < Project
  validates :url, presence: true, format: {with: /https?:\/\/.*\.rss$/i, message: 'should end with ".rss"'}

  def url
    feed_url
  end

  def url=(url)
    self.feed_url = url
  end

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def processor
    CruiseControlPayloadProcessor
  end

  def self.feed_url_fields
    ["URL"]
  end
end
