class StatusController < ApplicationController
  skip_filter :restrict_ip_address, :authenticate_user!

  def create
    project = Project.find_by_guid(params.delete(:project_id))

    payload = project.webhook_payload
    payload.webhook_status_content = request.body.read

    PayloadProcessor.new(project, payload).process

    project.save!
    head :ok
  end
end
