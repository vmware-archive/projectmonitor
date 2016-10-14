class ConcourseProject < Project

  validates_presence_of :ci_build_identifier, :ci_base_url, :concourse_pipeline_name

  alias_attribute :build_status_url, :feed_url

  def feed_url
    "#{ci_base_url}/api/v1/teams/#{team_name}/pipelines/#{concourse_pipeline_name}/jobs/#{ci_build_identifier}/builds"
  end

  def auth_url
    "#{ci_base_url}/api/v1/teams/#{team_name}/auth/token"
  end

  def fetch_payload
    ConcoursePayload.new(feed_url)
  end

  def self.project_specific_attributes
    ['ci_base_url', 'team_name', 'concourse_pipeline_name', 'ci_build_identifier']
  end
end
