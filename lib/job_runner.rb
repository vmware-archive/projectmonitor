class JobRunner
  def initialize(project, polling_strategy, project_complete)
    @project = project
    @polling_strategy = polling_strategy
    @project_complete = project_complete
  end

  def run(job_id, job_url)
    @polling_strategy.fetch_status(@project, job_url) do |polling_status, client_response_or_error, response_code|
      project_polled_successfully = polling_status == PollState::SUCCEEDED && (200..299).include?(response_code)

      job_result = {
          job_id: job_id,
          success: project_polled_successfully,
          response: client_response_or_error
      }
      yield job_result
    end
  end

  def jobs_complete(results)
    success = results.all? {|result| result[:success] == true }
    response = success ? job_results(results) : first_error(results)
    @project_complete.call(success, response)
  end

  private

  def job_results(results)
    results.inject({}) do |memo, result|
      memo[result[:job_id]] = result[:response]
      memo
    end
  end

  def first_error(results)
    failed_result = results.detect { |result| result[:success] == false }
    failed_result[:response]
  end
end