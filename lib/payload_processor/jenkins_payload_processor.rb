class JenkinsPayloadProcessor < ProjectPayloadProcessor
  private

  def parse_building_status
    building = false
    if payload && building_payload = payload.last
      document = Nokogiri::XML.parse(building_payload.downcase)
      p_element = document.xpath("//project[@name=\"#{project.project_name.downcase}\"]")
      return building_status if p_element.empty?
      building = p_element.attribute('activity').value == 'building'
    end
    building
  end

  def parse_project_status
    status = ProjectStatus.new(:online => false, :success => false)

    if payload && project_payload = payload.first
      if latest_build = Nokogiri::XML.parse(project_payload.downcase).css('feed entry:first').first
        if title = find(latest_build, 'title')
          status.success = !!(title.first.content.downcase =~ /success|stable|back to normal/)
        end
      end
      if status.url = find(latest_build, 'link')
        status.url = status.url.first.attribute('href').value
        pub_date = Time.parse(find(latest_build, 'published').first.content)
        status.published_at = (pub_date == Time.at(0) ? Time.now : pub_date).localtime
      end
      status
    end
  end
end
