class HudsonStatusParser < StatusParser
  class << self
    def building(content, project)
      building_parser = self.new
      document = Nokogiri::XML.parse(content.downcase)
      p_element = document.xpath("//project[@name=\"#{project.project_name.downcase}\"]")
      return building_parser if p_element.empty?
      building_parser.building = p_element.attribute('activity').value == 'building'
      building_parser
    end

    def status(content)
      status_parser = self.new
      begin
        latest_build = Nokogiri::XML.parse(content.downcase).css('feed entry:first').first
        status_parser.success = !!(find(latest_build, 'title').first.content =~ /success/)
        status_parser.url = find(latest_build, 'link').first.attribute('href').value
        pub_date = Time.parse(find(latest_build, 'published').first.content)
        status_parser.published_at = (pub_date == Time.at(0) ? Clock.now : pub_date).localtime
      rescue
      end
      status_parser
    end

    def find(document, path)
      document.css("#{path}") if document
    end
  end
end

