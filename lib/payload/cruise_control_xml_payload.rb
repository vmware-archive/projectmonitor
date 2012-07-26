class CruiseControlXmlPayload < Payload
  def building?
    project_element = build_status_content.at_xpath("/projects/project[@name='#{project.project_name.downcase}']")
    project_element && project_element['activity'] == "building"
  end

  private

  def convert_content!(content)
    [Nokogiri::XML(content.downcase)]
  end

  def convert_build_content!(content)
    Nokogiri::XML(content.downcase)
  end

  def parse_success(content)
    title = content.css('title')
    !!(title.to_s =~ /success/) if title.present?
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
