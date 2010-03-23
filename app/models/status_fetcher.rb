
class StatusFetcher
  def initialize(url_retriever = UrlRetriever.new)
    @url_retriever = url_retriever
  end

  def fetch_all
    errors = []
    projects = Project.find(:all)
    projects.each do |project|
      status = fetch_build_history(project)
      errors << status[:error] if status[:error]

      # Ignoring errors fetching building status at the moment.  Do we care?
      fetch_building_status(project)
    end

    unless errors.empty?
      error_msg = errors.join("\n")
      STDERR.puts(error_msg) unless RAILS_ENV == 'test' # TODO: better way to write to stderr without spamming test output?
      raise "ALL projects had errors fetching status" if errors.size == projects.size
    end
    0
  end

  def fetch_build_history(project)
    returning(retrieve_status_for(project)) do |current_status|
      project.statuses.build(current_status).save unless project.status.match?(current_status)
    end
  end

  def fetch_building_status(project)
    returning(retrieve_building_status_for(project)) do |building_status|
      project.update_attribute(:building, building_status[:building])
    end
  end

  private

  def retrieve_status_for(project)
    status = {:online => false, :success => false}
    status[:error] = http_errors_for(project) do
      content = @url_retriever.retrieve_content_at(project.feed_url, project.auth_username, project.auth_password)
      status_parser = project.status_parser(content)
      status[:success] = status_parser.success?
      status[:url] = status_parser.url
      status[:published_at] = status_parser.published_at
      status[:online] = true
    end
    status
  end

  def retrieve_building_status_for(project)
    status = { :building => false }
    status[:error] = http_errors_for(project) do
      content = @url_retriever.retrieve_content_at(project.build_status_url, project.auth_username, project.auth_password)
      building_parser = project.building_parser(content)
      status[:building] = building_parser.building?
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
