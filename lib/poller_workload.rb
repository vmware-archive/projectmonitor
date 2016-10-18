class PollerWorkload

  attr_accessor :job_urls

  def initialize
    @job_urls = {}
  end

  def add_job(key, url)
    return if url.nil?
    @job_urls[key] = url
  end
end
