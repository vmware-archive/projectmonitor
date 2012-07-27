class TeamCityChainedProject < TeamCityRestProject

  def fetch_payload
    TeamCityChainedXmlPayload.new(self)
  end

  def webhook_payload
    TeamCityChainedXmlPayload.new(self)
  end

  def children
    dependency_content = UrlRetriever.retrieve_content_at(build_type_url, auth_username, auth_password)

    parsed_content = Nokogiri::XML(dependency_content)
    child_build_ids = parsed_content.xpath("//snapshot-dependency").collect {|d| d.attributes["id"]}

    child_build_ids.map do |child_id|
      child_project = TeamCityChainedProject.new(
        :team_city_rest_base_url => team_city_rest_base_url,
        :team_city_rest_build_type_id => child_id
      )
      payload = child_project.fetch_payload
      payload.status_content = UrlRetriever.retrieve_content_at(
        child_project.feed_url, auth_username, auth_password
      )
      PayloadProcessor.new(child_project, payload)
      child_project
    end
  rescue Net::HTTPError
    []
  end

  private

  def build_type_url
    "http://#{team_city_rest_base_url}/httpAuth/app/rest/buildTypes/id:#{team_city_rest_build_type_id}"
  end

  def self.project_attribute_prefix
    'team_city_rest'
  end

end
