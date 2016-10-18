class BatchJobRunner

  def run(jobs, job_runner)
    results = []
    jobs.each do |job_id, job_url|
      job_runner.run(job_id, job_url) do |result|
        results << result
        if results.size == jobs.size
          job_runner.jobs_complete(results)
        end
      end
    end
  end

end