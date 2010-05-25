class TeamCityStatusParser < StatusParser
  class << self
    def building(content, project)
      building_parser = self.new
      document = Nokogiri::XML.parse(content)
      p_element = document.css("Build")
      return building_parser if p_element.empty?
      building_parser.building = p_element.attribute('activity').value == 'Building'
      building_parser
    end

    def status(content)
      status_parser = self.new
      begin
        latest_build = Nokogiri::XML.parse(content).css('Build').first
        status_parser.success = latest_build.attribute('lastBuildStatus').value == "NORMAL"
        status_parser.url = latest_build.attribute('webUrl').value
        pub_date = Time.parse(latest_build.attribute('lastBuildTime').value)
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

