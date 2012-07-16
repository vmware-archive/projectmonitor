
class CruiseControlProject < Project
  validates_format_of :feed_url, :with => /https?:\/\/.*\.rss$/, :message => 'should end with ".rss"'

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

  def self.build_url_from_fields(params)
    params["URL"]
  end
end
