class ProjectWorkloadHandler

  attr_reader :project

  def initialize(project, payload_processor: PayloadProcessor.new(project_status_updater: StatusUpdater.new))
    @project = project
    @payload_processor = payload_processor
  end

  def workload_complete(job_results)
    status_content = job_results[:feed_url]
    build_status_content = job_results[:build_status_url]

    update_ci_status(status_content, build_status_content)
  end

  def workload_failed(e)
    error_text = e.try(:message)
    error_backtrace = e.try(:backtrace).try(:join,"\n")
    project.payload_log_entries.build(error_type: "#{e.class}", error_text: "#{e.try(:message)}", update_method: 'Polling', status: 'failed', backtrace: "#{error_text}\n#{error_backtrace}")
    project.building = false
    project.online = false
    project.save!
  end

private

  def update_ci_status(status_content, build_status_content = nil)
    payload = project.fetch_payload

    payload.status_content = status_content
    payload.build_status_content = build_status_content if project.build_status_url

    log = @payload_processor.process_payload(project: project, payload: payload)
    log.update_method = 'Polling'

    project.payload_log_entries << log
    project.online = true
    project.save!

  rescue => e
    project.reload
    project.payload_log_entries.build(error_type: "#{e.class}", error_text: "#{e.message}", update_method: 'Polling', status: 'failed', backtrace: "#{e.message}\n#{e.backtrace.join("\n")}")
    project.online = false
    project.save!
  end

end
