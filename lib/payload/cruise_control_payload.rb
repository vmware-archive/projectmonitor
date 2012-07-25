class CruiseControlPayload < Payload
  def self.for_format(format)
    CruiseControlPayload
  end

  def success
    title = @content.css('title')
    return unless title.present?
    !!(title.to_s =~ /success/)
  end

  def url
    if url = @content.css('item/link')
      url.text
    end
  end

  def build_id
    url.split('/').last
  end

  def published_at
    if (pub_date = @content.css('pubdate')).present?
      pub_date = Time.parse(pub_date.text)
      (pub_date == Time.at(0) ? Time.now : pub_date).localtime
    end
  end

  def building?
    project_element = @build_status_content.at_xpath("/projects/project[@name='#{project.project_name.downcase}']")
    project_element && project_element['activity'] == "building"
  end

  private

  def convert_content!
    @status_content = [Nokogiri::XML(status_content.downcase)]
  end

  def convert_build_content!
    @build_status_content = Nokogiri::XML(build_status_content.downcase)
  end
end
