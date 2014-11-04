class ConcourseProject < Project

  validates_presence_of :ci_build_identifier, :ci_base_url

  alias_attribute :build_status_url, :feed_url

  def feed_url
    "#{ci_base_url}/api/v1/jobs/#{ci_build_identifier}/builds"
  end

  def fetch_payload
    ConcoursePayload.new("#{ci_base_url}/jobs/#{ci_build_identifier}/builds")
  end
end
