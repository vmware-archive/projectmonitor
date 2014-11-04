class TddiumProject < Project

  validates_presence_of :ci_build_identifier, :tddium_auth_token, unless: ->(project) { project.webhooks_enabled }

  alias_attribute :build_status_url, :feed_url

  def feed_url
    "https://api.tddium.com/cc/#{tddium_auth_token}/cctray.xml"
  end

  def fetch_payload
    TddiumPayload.new(ci_build_identifier)
  end

end
