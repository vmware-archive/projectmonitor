require 'nokogiri'
class CruiseControlProject < Project
  validates_format_of :feed_url, :with => /https?:\/\/.*\.rss$/, :message => 'should end with ".rss"'

  def project_name
    return nil if feed_url.nil?
    URI.parse(feed_url).path.scan(/^.*\/(.*)\.rss/i)[0][0]
  end

  def parse_building_status(content)
    status = super(content)

    document = Nokogiri::XML(content.downcase)
    project_element = document.at_xpath("/projects/project[@name='#{project_name.downcase}']")
    status.building = project_element && project_element['activity'] == "building"

    status
  end

  def parse_project_status(content)
    status = super(content)

    document = Nokogiri::XML(content)
    status.success = !!(find(document, 'title') =~ /success/)
    status.url = find(document, 'link')
    pub_date = Time.parse(find(document, 'pubDate'))
    status.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime

    status
  end

  def find(document, path)
    document.at_xpath("/rss/channel/item[1]/#{path}").content
  end

  def self.feed_url_fields
    ["URL"]
  end

  def self.build_url_from_fields(params)
    params["URL"]
  end
end
