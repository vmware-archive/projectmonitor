class ProjectContentFetcher
  delegate :feed_url, :build_status_url, :auth_username, :auth_password, to: :project

  def initialize(project)
    self.project = project
  end

  def fetch
    status_content = fetch_status if project.feed_url

    if project.feed_url == project.build_status_url
      status_content
    else
      building_status_content = fetch_building_status if project.build_status_url
      [status_content, building_status_content]
    end
  end

  private

  def fetch_status
    content = UrlRetriever.retrieve_content_at(feed_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    project.offline!
    nil
  end

  def fetch_building_status
    content = UrlRetriever.retrieve_content_at(build_status_url, auth_username, auth_password)
  rescue Net::HTTPError => e
    project.update_attributes!(building: false)
    nil
  end

  attr_accessor :project
end
