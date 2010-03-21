require 'xml/libxml'
class CruiseControlStatusParser
  attr_accessor :success, :building, :url, :published_at

  def self.building(content, project)
    building_parser = self.new
    document = XML::Parser.string(content.downcase).parse
    project_element = document.find_first("/projects/project[@name='#{project.project_name.downcase}']")
    building_parser.building = project_element && project_element.attributes['activity'] == "building"
    building_parser
  end

  def self.status(content)
    status_parser = self.new
    document = XML::Parser.string(content).parse
    status_parser.success = !!(find(document, 'title') =~ /success/)
    status_parser.url = find(document, 'link')
    pub_date = Time.parse(find(document, 'pubDate'))
    status_parser.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
    status_parser
  end

  def self.find(document, path)
    document.find_first("/rss/channel/item[1]/#{path}").content
  end

  def building?
    @building
  end

  def success?
    @success
  end

end

