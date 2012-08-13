class StatusController < ApplicationController
  def create
    project = Project.find_by_guid(params.delete(:project_id))
    payload = project.webhook_payload
    payload.status_content = params
    PayloadProcessor.new(project, payload).process
    project.update_attributes!(last_refreshed_at: Time.now)
    head :ok
  end
end
