class TddiumProject < Project

  validates_presence_of :ci_build_identifier, :ci_auth_token, unless: ->(project) { project.webhooks_enabled }

  alias_attribute :build_status_url, :feed_url

  def self.project_specific_attributes
    ['ci_auth_token', 'ci_build_identifier']
  end

  def feed_url
    "https://api.tddium.com/cc/#{ci_auth_token}/cctray.xml"
  end

  def fetch_payload
    TddiumPayload.new(ci_build_identifier)
  end

end
