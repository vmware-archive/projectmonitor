class JenkinsXmlPayload < Payload

  def initialize(build_name)
    super()
    @build_name = build_name
  end

  def building?
    p_element = build_status_content.xpath(".//project[@name = '#{@build_name.downcase}']")
    p_element.present? && p_element.attribute('activity').value == 'building'
  end

  private

  def content_ready?(content)
    content.css('title').present?
  end

  def convert_content!(raw_content)
    Array.wrap(convert_xml_content!(raw_content).css('feed entry'))
  end

  alias_method :convert_build_content!, :convert_xml_content!

  def parse_success(content)
    !!(content.css('title').first.content.downcase =~ /success|stable|back to normal/)
  end

  def parse_url(content)
    if link = content.css('link').first
      link.attribute('href').value
    end
  end

  def parse_build_id(content)
    if url = parse_url(content)
      url.split('/').last
    end
  end

  def parse_published_at(content)
    pub_date = Time.parse(content.css('published').first.content)
    (pub_date == Time.at(0) ? Time.now : pub_date).localtime
  end

end
