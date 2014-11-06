class CodeshipProject < Project

  validates_presence_of :ci_build_identifier
  validates_presence_of :ci_auth_token, unless: :webhooks_enabled

  def self.project_specific_attributes
    ["ci_build_identifier", "ci_auth_token"]
  end

  def feed_url
    "https://www.codeship.io/api/v1/projects/#{ci_build_identifier}.json?api_key=#{ci_auth_token}"
  end

  def build_status_url
    "https://www.codeship.io/projects/#{ci_build_identifier}"
  end

  def fetch_payload
    CodeshipPayload.new(ci_build_identifier)
  end

  alias_method :webhook_payload, :fetch_payload
end
