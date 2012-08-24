class TeamCityXmlPayload < Payload

  def initialize(project)
    super()
    @project = project
  end

  def building?
    status_content.first.attribute('running').present?
  end

  def build_status_is_processable?
    status_is_processable?
  end

  def dependent_projects
    children_build_details.collect do |child_id|
      @project.dup.tap do |child_project|
        child_project.team_city_rest_build_type_id = child_id
      end
    end
  end

  private

  def content_ready?(content)
    return false if content.attribute('running').present? && content.attribute('status').value != 'FAILURE'
    return false if content.attribute('status').value == 'UNKNOWN'
    true
  end

  def children_build_details
    return [] unless has_dependent_content?
    selector = XPath.descendant(:'snapshot-dependency').to_s
    Nokogiri::XML(dependent_content).xpath(selector).collect {|d| d.attributes['id'].value }
  end

  def convert_content!(content)
    parsed_content = Nokogiri::XML.parse(content)
    raise Payload::InvalidContentException, "Error converting content for project #{@project_name}" unless parsed_content.root
    parsed_content.css('build').to_a
  end

  def parse_success(content)
    content.attribute('status').value == 'SUCCESS'
  end

  def parse_url(content)
    content.attribute('webUrl').value
  end

  def parse_build_id(content)
    content.attribute('id').value
  end

  def parse_published_at(content)
    parse_start_date_attribute(content.attribute('startDate'))
  end

  def parse_start_date_attribute(start_date_attribute)
    if start_date_attribute.present?
      Time.parse(start_date_attribute.value).localtime
    else
      Time.now.localtime
    end
  end
end
