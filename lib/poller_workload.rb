class PollerWorkload

  def initialize(handler)
    @handler = handler
    @job_descriptions = {}
    @job_results = {}

    @handler.workload_created(self)
  end

  def unfinished_job_descriptions
    @job_descriptions.reject {|job_id, _| complete_job_ids.include?(job_id)}
  end

  def incomplete_jobs
    @job_descriptions.keys - complete_job_ids
  end

  def complete_job_ids
    @job_results.keys
  end

  def complete?
    incomplete_jobs.empty?
  end

  def recall(key)
    @job_results[key]
  end

  def store(key, content)
    @job_results[key] = content
    @handler.workload_complete(self) if complete?
  end

  def failed(error)
    @handler.workload_failed(self, error)
  end

  def add_job(key, url)
    return if url.nil?
    @job_descriptions[key] = url
  end

end
