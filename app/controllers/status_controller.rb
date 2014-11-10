class StatusController < ApplicationController
  skip_filter :restrict_ip_address, :authenticate_user!

  def create
    if project = Project.find_by_guid(params.delete(:project_id))
      payload = project.webhook_payload
      payload.remote_addr = request.env["REMOTE_ADDR"]

      payload.webhook_status_content =
        case payload
        when TeamCityJsonPayload, SemaphorePayload, CodeshipPayload, TravisJsonPayload
          params
        when JenkinsJsonPayload
          params['build'].present? ? params.to_json : request.body.read
        else
          request.body.read
        end

      log = PayloadProcessor.new(project_status_updater: StatusUpdater.new).process_payload(project: project, payload: payload)
      log.update_method = "Webhooks"
      log.save!

      project.save!
      head :ok
    else
      head :not_found
    end
  end
end
