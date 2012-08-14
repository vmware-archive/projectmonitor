class TrackerProjectValidator
  def self.validate params
    project = Project.find(params[:id])
    begin
      PivotalTracker::Client.use_ssl = true
      PivotalTracker::Client.token = params[:auth_token]
      PivotalTracker::Project.find(params[:project_id])
      status = :ok
    rescue RestClient::Unauthorized
      status = :unauthorized
    rescue RestClient::ResourceNotFound
      status = :not_found
    end
    project.tracker_validation_status = {auth_token: params[:auth_token], project_id: params[:project_id], status: status}
    project.save!
  end
end
