class JenkinsXmlPayload < Payload

  def initialize(build_name)
    super()
    @build_name = build_name
  end

  def building?
    selector = XPath.descendant(:project)[XPath.attr(:name) == @build_name.downcase].to_s
    p_element = build_status_content.xpath selector
    p_element.present? && p_element.attribute('activity').value == 'building'
  end

  private

  def convert_content!(content)
    parsed_content = parse_content(content.downcase)
    parsed_content.css('feed entry').to_a
  end

  def convert_build_content!(content)
    parse_content(content)
  end

  def parse_content(content)
    parsed_content = Nokogiri::XML.parse(content.downcase)
    if parsed_content.root
      return parsed_content
    else
      raise Payload::InvalidContentException, "Error parsing content for build name #{@build_name}"
      self.processable = false
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
