class StatusFetcher
  def initialize(url_retriever = UrlRetriever.new)
    @url_retriever = url_retriever
  end

  def fetch_all
    errors = []
    projects = Project.find(:all)
    projects.reject! {|project| !project.needs_poll?}
    projects.each do |project|
      status = fetch_build_history(project)
      errors << status.error if status.error

      # Ignoring errors fetching building status at the moment.  Do we care?
      fetch_building_status(project)
      project.set_next_poll!
    end

    unless errors.empty?
      error_msg = errors.join("\n")
      STDERR.puts(error_msg) unless Rails.env.test? # TODO: better way to write to stderr without spamming test output?
      raise "ALL projects had errors fetching status" if errors.size == projects.size
    end
    0
  end

  def fetch_build_history(project)
    current_status = retrieve_status_for(project)
    project.statuses.build(current_status.attributes).save unless project.status.match?(current_status)
    current_status
  end

  def fetch_building_status(project)
    building_status = retrieve_building_status_for(project)
    project.update_attribute(:building, building_status.building?)
    building_status
  end

  private

  def retrieve_status_for(project)
    status = ProjectStatus.new(:online => false, :success => false)
    status.error = http_errors_for(project) do
      content = @url_retriever.retrieve_content_at(project.feed_url, project.auth_username, project.auth_password)
      status = project.parse_project_status(content)
      status.online = true
    end
    status
  end

  def retrieve_building_status_for(project)
    status = BuildingStatus.new(false)
    status.error = http_errors_for(project) do
      content = @url_retriever.retrieve_content_at(project.build_status_url, project.auth_username, project.auth_password)
      status = project.parse_building_status(content)
    end
    status
  end

  private

  def http_errors_for(project)
    yield
    nil
  rescue URI::InvalidURIError => e
    "Invalid URI for project '#{project}': #{e.message}"
  rescue Net::HTTPError => e
    "HTTP Error retrieving status for project '#{project}': #{e.message}"
  rescue Exception => e
    "Retrieve Status failed for project '#{project}'.  Exception: '#{e.class}: #{e.message}'\n#{e.backtrace.join("\n")}"
  end
end
