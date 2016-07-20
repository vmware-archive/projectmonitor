class StatusController < ApplicationController
  skip_before_action :restrict_ip_address, :authenticate_user!, raise: false

  def create
    if project = Project.find_by_guid(params.delete(:project_id))
      payload = project.webhook_payload
      payload.remote_addr = request.env['REMOTE_ADDR']

      payload.webhook_status_content =
        case payload
          when TeamCityJsonPayload, SemaphorePayload, CodeshipPayload, TravisJsonPayload, JenkinsJsonPayload, CircleCiPayload
            params_for_webhook_status_content(payload)
          else
            request.body.read
        end

      log = PayloadProcessor.new(project_status_updater: StatusUpdater.new).process_payload(project: project, payload: payload)
      log.update_method = 'Webhooks'
      log.save!

      project.save!
      head :ok
    else
      head :not_found
    end
  end

  private

  def params_for_webhook_status_content(payload)
    if is_legacy_jenkins_notification?(payload)
      params.merge(parse_legacy_jenkins_notification)
    else
      params
    end
  end

  # Jenkins notification plugin did not set content-type prior to 1.5
  def is_legacy_jenkins_notification?(payload)
    payload.is_a?(JenkinsJsonPayload) && params['build'].nil?
  end

  def parse_legacy_jenkins_notification
    begin
      JSON.parse(request.body.read)
    rescue => e
      raise ActionDispatch::ParamsParser::ParseError.new
    end
  end
end
