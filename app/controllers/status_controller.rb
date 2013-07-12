class StatusController < ApplicationController
  skip_filter :restrict_ip_address, :authenticate_user!

  def create
    if project = Project.find_by_guid(params.delete(:project_id))
      payload = project.webhook_payload
      payload.remote_addr = request.env["REMOTE_ADDR"]

      if payload.instance_of?(TeamCityJsonPayload)
        payload.webhook_status_content = params['build'].to_json
      elsif payload.instance_of?(SemaphorePayload)
        payload.webhook_status_content = params.to_json
      else
        payload.webhook_status_content = request.body.read
      end

      log = PayloadProcessor.new(project, payload).process
      log.update_method = "Webhooks"
      log.save!

      project.save!
      head :ok
    else
      head :not_found
    end
  end
end
