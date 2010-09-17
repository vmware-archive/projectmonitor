class HudsonProject < Project
  validates_format_of :feed_url, :with =>  /http:\/\/.*job\/.*\/rssAll$/

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*job\/(.*)/i)[0][0].split('/').first
  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    returning("#{url_components.scheme}://#{url_components.host}") do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/cc.xml"
    end
  end

  def building_parser(content)
    building_parser = StatusParser.new
    document = Nokogiri::XML.parse(content.downcase)
    p_element = document.xpath("//project[@name=\"#{project_name.downcase}\"]")
    return building_parser if p_element.empty?
    building_parser.building = p_element.attribute('activity').value == 'building'
    building_parser
  end

  def status_parser(content)
    status_parser = StatusParser.new
    begin
      latest_build = Nokogiri::XML.parse(content.downcase).css('feed entry:first').first
      status_parser.success = !!(find(latest_build, 'title').first.content =~ /success/)
      status_parser.url = find(latest_build, 'link').first.attribute('href').value
      pub_date = Time.parse(find(latest_build, 'published').first.content)
      status_parser.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    rescue
    end
    status_parser
  end

  def find(document, path)
    document.css("#{path}") if document
  end

end