class CruiseControlProject < Project
  validates_format_of :feed_url, :with => /http:\/\/.*.rss$/
  
  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def building_parser(content)
    building_parser = StatusParser.new
    document = XML::Parser.string(content.downcase).parse
    project_element = document.find_first("/projects/project[@name='#{project_name.downcase}']")
    building_parser.building = project_element && project_element.attributes['activity'] == "building"
    building_parser
  end

  def status_parser(content)
    status_parser = StatusParser.new
    document = XML::Parser.string(content).parse
    status_parser.success = !!(find(document, 'title') =~ /success/)
    status_parser.url = find(document, 'link')
    pub_date = Time.parse(find(document, 'pubDate'))
    status_parser.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    status_parser
  end

  def find(document, path)
    document.find_first("/rss/channel/item[1]/#{path}").content
  end
end