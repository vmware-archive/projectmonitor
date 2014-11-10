class StatusController < ApplicationController
  skip_filter :restrict_ip_address, :authenticate_user!

  def create
    if project = Project.find_by_guid(params.delete(:project_id))
      payload = project.webhook_payload
      payload.remote_addr = request.env["REMOTE_ADDR"]

      params.merge!(parse_legacy_jenkins_notification) if is_legacy_jenkins_notification?(payload)

      payload.webhook_status_content =
        case payload
        when TeamCityJsonPayload, SemaphorePayload, CodeshipPayload, TravisJsonPayload, JenkinsJsonPayload
          params
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

  private

  # Jenkins notification plugin did not set content-type prior to 1.5
  def is_legacy_jenkins_notification?(payload)
    payload.is_a?(JenkinsJsonPayload) && params['build'].nil?
  end

  def parse_legacy_jenkins_notification
    begin
      JSON.parse(request.body.read)
    rescue => e
      raise ActionDispatch::ParamsParser::ParseError.new(e.message, e)
    end
  end
end
