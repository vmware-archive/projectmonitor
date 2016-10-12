class ProjectPoller
  def poll_project(project, polling_strategy, workload, &project_complete)
    workload.unfinished_job_descriptions.each do |job_id, job_description|
      polling_strategy.fetch_status(project, job_description) do |polling_status, client_response_or_error|
        handler = polling_strategy.create_handler(project)
        if polling_status == PollState::SUCCEEDED
          workload.store(job_id, client_response_or_error)
          if workload.complete?
            handler.workload_complete(workload)
            project_complete.call
          end
        else # FAILURE
          handler.workload_failed(client_response_or_error)
          project_complete.call
        end
      end
    end
  end
end