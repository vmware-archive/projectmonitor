class TeamCityChainedProject < TeamCityRestProject
  def process_status_update
    parsed_status = parse_project_status
    parsed_status.online = true
    statuses.create(parsed_status.attributes) unless status.match?(parsed_status)

  rescue Net::HTTPError => e
    error = "HTTP Error retrieving status for project '##{id}': #{e.message}"
    statuses.create(:error => error) unless status.error == error
  end

  private

  def live_status
    content = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
    status_elem = Nokogiri::XML.parse(content).css('build').detect { |se|
      !se.attribute('running') || se.attribute('status').value != "SUCCESS"
    }

    status = ProjectStatus.new(:project => self, :online => true)
    status.success = status_elem.attribute('status').value == "SUCCESS"
    status.url = status_elem.attribute('webUrl').value
    status.published_at = Clock.now
    status
  end

  def parse_project_status
    status = live_status
    return status unless status.success?
    status.success = false if children.any?(&:red?)
    status
  end

  def children
    TeamCityChildBuilder.parse(self, build_type_fetcher.call)
  rescue Net::HTTPError
    []
  end

  def build_type_url
    uri = URI(feed_url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/httpAuth/app/rest/buildTypes/id:#{build_id}"
  end

  def build_id
    feed_url.match(/id:([^)]*)/)[1]
  end

  def build_type_fetcher
    @build_type_fetcher ||= proc {
      UrlRetriever.retrieve_content_at(build_type_url, auth_username, auth_password)
    }
  end

end
