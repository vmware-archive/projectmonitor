class TeamCityChildProject
  attr_accessor :feed_url, :auth_username, :auth_password, :build_id

  def initialize(opts)
    self.feed_url, self.auth_username, self.auth_password, self.build_id =
      opts.values_at(:feed_url, :auth_username, :auth_password, :build_id)
  end

  def red?
    live_status != 'SUCCESS' || children.any?(&:red?)
  end

  def last_build_time
    [live_build_time, *children.map(&:last_build_time)].max
  end

  private

  def live_status
    newest_build_node.attribute('status').value
  end

  def live_build_time
    if newest_build_node.attribute('startDate').present?
      Time.parse(newest_build_node.attribute('startDate').value).localtime
    else
      Clock.now.localtime
    end
  end

  def newest_build_node
    @newest_build_node ||= begin
      content = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
      status_elem = Nokogiri::XML.parse(content).css('build').reject { |se|
        se.attribute('status').value == 'UNKNOWN'
      }.
      detect { |se|
        !se.attribute('running') || se.attribute('status').value != "SUCCESS"
      }
    end
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
