class TrackerProjectValidator
  def self.validate params
    PivotalTracker::Client.use_ssl = true
    PivotalTracker::Client.token = params[:auth_token]
    PivotalTracker::Project.find(params[:project_id])
    :ok
  rescue RestClient::Unauthorized
    :unauthorized
  rescue RestClient::ResourceNotFound
    :not_found
  end
end
