class CircleCiProject < Project

  validates_presence_of :circleci_username, :circleci_project_name, :circleci_auth_token, unless: ->(project) { project.webhooks_enabled }

  def self.project_specific_attributes
    columns.map(&:name).grep(/circleci_/)
  end

  def build_status_url
    feed_url
  end

  def feed_url
    "https://circleci.com/api/v1/project/#{circleci_username}/#{circleci_project_name}?circle-token=#{circleci_auth_token}"
  end

  def fetch_payload
    CircleCiPayload.new
  end

  def accept_mime_types
    "application/json"
  end

end
