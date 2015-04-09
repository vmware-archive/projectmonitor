class TravisProProject < TravisProject
  BASE_API_URL = 'https://api.travis-ci.com'

  validates_presence_of :ci_auth_token, unless: ->(project) { project.webhooks_enabled }

  def self.project_specific_attributes
    super << 'ci_auth_token'
  end

  # Add ?token= or &token= to the feed_url, as appropriate
  def feed_url
    URI.parse(super).tap do |uri|
      params = URI.decode_www_form(uri.query || []) << ['token', ci_auth_token]
      uri.query = URI.encode_www_form(params)
    end.to_s
  end

  def fetch_payload
    super.tap { |payload| payload.is_travis_pro = true }
  end

  alias_method :webhook_payload, :fetch_payload
end
