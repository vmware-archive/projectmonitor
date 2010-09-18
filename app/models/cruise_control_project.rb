class CruiseControlProject < Project
  validates_format_of :feed_url, :with => /http:\/\/.*.rss$/
  
  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def parse_building_status(content)
    status = super(content)
    document = XML::Parser.string(content.downcase).parse
    project_element = document.find_first("/projects/project[@name='#{project_name.downcase}']")
    status.building = project_element && project_element.attributes['activity'] == "building"
    status
  end

  def parse_project_status(content)
    status = super(content)
    document = XML::Parser.string(content).parse
    status.success = !!(find(document, 'title') =~ /success/)
    status.url = find(document, 'link')
    pub_date = Time.parse(find(document, 'pubDate'))
    status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    status
  end

  def find(document, path)
    document.find_first("/rss/channel/item[1]/#{path}").content
  end
end