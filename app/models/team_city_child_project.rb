class TeamCityChildProject
  attr_accessor :feed_url, :auth_username, :auth_password, :build_id

  def initialize(opts)
    self.feed_url, self.auth_username, self.auth_password, self.build_id =
      opts.values_at(:feed_url, :auth_username, :auth_password, :build_id)
  end

  def red?
    live_status != 'SUCCESS' || children.any?(&:red?)
  end

  private

  def live_status
    content = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
    status_elem = Nokogiri::XML.parse(content).css('build').detect { |se|
      !se.attribute('running') || se.attribute('status').value != "SUCCESS"
    }
    status_elem.attribute('status').value
  end

  def children
    TeamCityChildBuilder.parse(self, build_type_fetcher.call)
  end

  def build_type_url
    uri = URI(feed_url)
    "#{uri.scheme}://#{uri.host}:#{uri.port}/httpAuth/app/rest/buildTypes/id:#{build_id}"
  end

  def build_type_fetcher
    @build_type_fetcher ||= proc {
      UrlRetriever.retrieve_content_at(build_type_url, auth_username, auth_password)
    }
  end
end
