class CodeshipProject < Project

  validates_presence_of :ci_build_identifier
  validates_presence_of :ci_auth_token, unless: :webhooks_enabled

  def self.project_specific_attributes
    ["ci_build_identifier", "ci_auth_token"]
  end

  def requires_branch_name?
    true
  end

  def feed_url
    "https://www.codeship.io/api/v1/projects/#{ci_build_identifier}.json?api_key=#{ci_auth_token}"
  end

  alias_method :build_status_url, :feed_url

  def fetch_payload
    CodeshipPayload.new(ci_build_identifier, build_branch)
  end

end
