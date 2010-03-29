class TeamCityProject < Project
  validates_format_of :feed_url, :with =>  /http:\/\/.*feed.html\?.*buildTypeId.*$/

#  def project_name
#    return nil if feed_url.nil?
#    URI.parse(feed_url).path.scan(/^.*job\/(.*)/i)[0][0].split('/').first
#  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    returning("#{url_components.scheme}://#{url_components.host}") do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/cc.xml"
    end
  end

  def building_parser(content)
    TeamCityStatusParser.building(content, self)
  end

  def status_parser(content)
    TeamCityStatusParser.status(content)
  end
end