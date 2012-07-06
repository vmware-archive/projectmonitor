class TravisProject < Project

  validates_format_of :feed_url,
    :with => %r(^https?://travis-ci.org/\w+/\w+/cc\.xml$),
    :message => "should look like: http://travis-ci.org/[account]/[project]/cc.xml"

  def project_name
    return nil if feed_url.nil?
    feed_url.split("/").last(2).first
  end

  def build_status_url
    feed_url
  end

  def parse_building_status(content)
    status = super(content)

    project = Nokogiri::XML.parse(content).css('Project').first
    status.building = project.attribute("activity").value == "Building" if project
    status
  end

  def parse_project_status(content)
    status = super(content)
    project = Nokogiri::XML.parse(content).css('Project').first

    status.success = project.attribute("lastBuildStatus").value == "Success"
    status.url = project.attribute("webUrl").value

    published_at = project.attribute("lastBuildTime").value
    status.published_at = Time.parse(published_at).localtime if published_at.present?

    status
  end

  def find(document, path)
    document.css("#{path}") if document
  end

end
