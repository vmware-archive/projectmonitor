class PollerWorkload

  def initialize
    @job_descriptions = {}
    @job_results = {}
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
  end

  def add_job(key, url)
    return if url.nil?
    @job_descriptions[key] = url
  end

end
