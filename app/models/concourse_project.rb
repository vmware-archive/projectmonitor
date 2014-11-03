class ConcourseProject < Project

  validates_presence_of :concourse_job_name, :concourse_base_url

  alias_attribute :build_status_url, :feed_url
  alias_attribute :concourse_base_url, :ci_base_url

  def feed_url
    "#{concourse_base_url}/api/v1/jobs/#{concourse_job_name}/builds"
  end

  def fetch_payload
    ConcoursePayload.new("#{concourse_base_url}/jobs/#{concourse_job_name}/builds")
  end
end
