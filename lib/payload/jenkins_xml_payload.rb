class JenkinsXmlPayload < Payload
  def building?
    p_element = build_status_content.xpath("//project[@name=\"#{project.project_name.downcase}\"]")
    return false if p_element.empty?
    p_element.attribute('activity').value == 'building'
  end

  private

  def convert_content!(content)
    if content
      Nokogiri::XML.parse(content.downcase).css('feed entry').to_a
    else
      self.processable = false
      []
    end
  end

  def convert_build_content!(content)
    if content
      Nokogiri::XML.parse(content.downcase)
    else
      self.build_processable = false
    end
  end

  def parse_success(content)
    if (title = content.css('title')).present?
      !!(title.first.content.downcase =~ /success|stable|back to normal/)
    end
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
