class ProjectPoller
  def poll_project(project, polling_strategy, jobs, &project_complete)
    if jobs.empty?
      project_complete.call(false, 'no jobs found')
      return
    end

    error = nil
    job_results = {}
    jobs.each do |job_id, job_url|
      fetch_project_url(job_url, project, polling_strategy) do |success_flag, job_response|
        if !success_flag
          error = job_response
        end

        job_results[job_id] = job_response

        if job_results.size == jobs.size
          success = error.nil?
          response = success ? job_results : error
          project_complete.call(success, response)
        end
      end
    end
  end

  private

  def fetch_project_url(url, project, polling_strategy)
    polling_strategy.fetch_status(project, url) do |polling_status, client_response_or_error, response_code|
      project_polled_successfully = polling_status == PollState::SUCCEEDED && (200..299).include?(response_code)
      yield project_polled_successfully, client_response_or_error
    end
  end
end