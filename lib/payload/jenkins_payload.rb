class JenkinsPayload < Payload
  def self.for_format(format)
    format == :json ? JenkinsJsonPayload : JenkinsXmlPayload
  end
end

class JenkinsJsonPayload < JenkinsPayload
  def success
    # TODO: find actual return code for success
    @content["build"]["phase"] == "SUCCESS"
  end

  def url
    @content["build"]["url"]
  end

  def build_id
    @content["build"]["number"]
  end

  def published_at
    Time.now
  end

  def building?
    @status_content.first["build"]["phase"] == "STARTED"
  end

  private

  def convert_content!
    begin
      @status_content = [Array.wrap(JSON.parse(status_content.keys.first)).first]
    rescue JSON::ParserError
      self.processable = false
      self.build_processable = false
    end
  end
end

class JenkinsXmlPayload < JenkinsPayload
  def success
    if (title = @content.css('title')).present?
      !!(title.first.content.downcase =~ /success|stable|back to normal/)
    end
  end

  def url
    if link = @content.css('link').first
      link.attribute('href').value
    end
  end

  def build_id
    url.split('/').last
  end

  def published_at
    pub_date = Time.parse(@content.css('published').first.content)
    (pub_date == Time.at(0) ? Time.now : pub_date).localtime
  end

  def building?
    p_element = build_status_content.xpath("//project[@name=\"#{project.project_name.downcase}\"]")
    return false if p_element.empty?
    p_element.attribute('activity').value == 'building'
  end

  private

  def convert_content!
    if status_content
      @status_content = Nokogiri::XML.parse(status_content.downcase).css('feed entry')
    else
      self.processable = false
    end
  end

  def convert_build_content!
    if build_status_content
      @build_status_content = Nokogiri::XML.parse(build_status_content.downcase)
    else
      self.build_processable = false
    end
  end
end
