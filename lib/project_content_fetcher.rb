class ProjectContentFetcher
  delegate :feed_url, :build_status_url, :auth_username, :auth_password, to: :project
  attr_reader :payload

  def initialize(project)
    self.project = project
    self.payload = Payload.for_project(project)
  end

  def fetch
    fetch_status
    fetch_building_status unless one_url_for_both_status_and_building_status?

    payload
  end

  private

  def fetch_status
    payload.status_content = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    project.offline!
    # project.not_building! if one_url_for_both_status_and_building_status?
    nil
  end

  def fetch_building_status
    payload.build_status_content = UrlRetriever.retrieve_content_at(build_status_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    project.not_building!
    nil
  end

  def one_url_for_both_status_and_building_status?
    project.feed_url == project.build_status_url
  end

  attr_accessor :project
  attr_writer :payload
end
