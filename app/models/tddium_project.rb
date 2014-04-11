class TddiumProject < Project

  validates_presence_of :tddium_project_name, :tddium_auth_token, unless: ->(project) { project.webhooks_enabled }

  def build_status_url
    feed_url
  end

  def feed_url
    "https://api.tddium.com/cc/#{tddium_auth_token}/cctray.xml"
  end

  def fetch_payload
    TddiumPayload.new(tddium_project_name)
  end

end
