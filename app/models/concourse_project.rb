class ConcourseProject < Project

  validates_presence_of :ci_build_identifier, :ci_base_url, :concourse_pipeline_name

  alias_attribute :build_status_url, :feed_url

  def feed_url
    "#{ci_base_url}/api/v1/teams/main/pipelines/#{concourse_pipeline_name}/jobs/#{ci_build_identifier}/builds"
  end

  def fetch_payload
    ConcoursePayload.new(feed_url)
  end

  def self.project_specific_attributes
    ['concourse_pipeline_name', 'ci_build_identifier', 'ci_base_url']
  end
end
