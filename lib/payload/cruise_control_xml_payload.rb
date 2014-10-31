class CruiseControlXmlPayload < Payload

  def initialize(project_name)
    super()
    @project_name = project_name
  end

  def building?
    project_element = build_status_content.at_xpath(".//projects/project[@name = '#{@project_name.downcase}']")
    project_element.present? && project_element['activity'] == 'building'
  end

  private

  def convert_content!(raw_content)
    Array.wrap(convert_xml_content!(raw_content))
  end

  def convert_build_content!(raw_content)
    convert_xml_content!(raw_content)
  end

  def content_ready?(content)
    content.css('title').present?
  end

  def parse_success(content)
    !!(content.css('title').to_s =~ /success/)
  end

  def parse_url(content)
    if url = content.css('item/link')
      url.text
    end
  end

  def parse_build_id(content)
    if url = parse_url(content)
      url.split('/').last
    end
  end

  def parse_published_at(content)
    pub_date = content.css('pubdate')
    if pub_date.present?
      pub_date = Time.parse(pub_date.text)
      (pub_date == Time.at(0) ? Time.now : pub_date).localtime
    end
  end
end
