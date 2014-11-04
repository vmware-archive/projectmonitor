class CircleCiProject < Project

  validates_presence_of :circleci_username, :ci_build_identifier, :circleci_auth_token, unless: ->(project) { project.webhooks_enabled }

  alias_attribute :build_status_url, :feed_url

  def self.project_specific_attributes
    columns.map(&:name).grep(/circleci_/)
  end

  def feed_url
    "https://circleci.com/api/v1/project/#{circleci_username}/#{ci_build_identifier}?circle-token=#{circleci_auth_token}"
  end

  def fetch_payload
    CircleCiPayload.new
  end

  def accept_mime_types
    "application/json"
  end

end
