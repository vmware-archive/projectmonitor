module StatusFetcher
  extend self

  class Job < Struct.new(:project)
    def perform
      project.update_tracker_status!
      StatusFetcher.retrieve_status_for(project)
      StatusFetcher.retrieve_building_status_for(project)
      project.set_next_poll!
    end
  end

  def fetch_all
    projects = Project.all.select(&:needs_poll?)
    projects.each do |project|
      Delayed::Job.enqueue StatusFetcher::Job.new(project)
    end
  end

  def retrieve_status_for(project)
    content = UrlRetriever.retrieve_content_at(project.feed_url, project.auth_username, project.auth_password)
    status = project.parse_project_status(content)
    status.online = true
    project.statuses.create(status.attributes) unless project.status.match?(status)

  rescue Net::HTTPError => e
    error = "HTTP Error retrieving status for project '##{project.id}': #{e.message}"
    project.statuses.create(:error => error) unless project.status.error == error
  end

  def retrieve_building_status_for(project)
    content = UrlRetriever.retrieve_content_at(project.build_status_url, project.auth_username, project.auth_password)
    status = project.parse_building_status(content)
    project.update_attribute(:building, status.building?)
  rescue Net::HTTPError => e
    project.update_attribute(:building, false)
  end

end

