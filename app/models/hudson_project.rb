class HudsonProject < Project
  validates_format_of :feed_url, :with =>  /http:\/\/.*job\/.*\/rssAll$/

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*job\/(.*)/i)[0][0].split('/').first
  end

  def building_parser(content)
    HudsonStatusParser.building(content, self)
  end

  def status_parser(content)
    HudsonStatusParser.status(content)
  end
end