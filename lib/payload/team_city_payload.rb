class TeamCityPayload < Payload
  def self.for_format(format)
    format == :json ? TeamCityJsonPayload : TeamCityXmlPayload
  end
end

class TeamCityXmlPayload < TeamCityPayload
  def success
    return if @content.attribute('running').present? && @content.attribute('status').value != 'FAILURE'
    @content.attribute('status').value == 'SUCCESS'
  end

  def url
    @content.attribute('webUrl').value
  end

  def build_id
    @content.attribute('id').value
  end

  def published_at
    parse_start_date_attribute(@content.attribute('startDate'))
  end

  def building?
    @status_content.first.attribute('running').present?
  end

  def convert_content!
    @status_content = Nokogiri::XML.parse(status_content).css('build').to_a.first(50)
  end

  def build_status_is_processable?
    status_is_processable?
  end

  private

  def parse_start_date_attribute(start_date_attribute)
    if start_date_attribute.present?
      Time.parse(start_date_attribute.value).localtime
    else
      Time.now.localtime
    end
  end
end

class TeamCityJsonPayload < TeamCityPayload
  def success
    @content["buildResult"] == "success"
  end

  def url
    project.feed_url
  end

  def build_id
    @content["buildId"]
  end

  def published_at
    Time.now
  end

  def building?
    @status_content.first["buildResult"] == "running" && @status_content.first["notifyType"] == "buildStarted"
  end

  private

  def convert_content!
    @status_content = [status_content["build"]]
  end
end

# class TeamCityPayloadProcessor < ProjectPayloadProcessor
  # def live_status_hashes
    # live_builds.reject { |status|
      # status[:status] == 'UNKNOWN' || (status[:running] && status[:status] == 'SUCCESS')
    # }
  # end
# end
