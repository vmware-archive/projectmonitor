class JenkinsProject < Project
  validates_presence_of :ci_base_url, :ci_build_identifier, unless: :webhooks_enabled

  alias_attribute :project_name, :ci_build_identifier

  def feed_url
    "#{ci_base_url}/job/#{ci_build_identifier}/rssAll"
  end

  def build_status_url
    "#{ci_base_url}/cc.xml" if ci_base_url.present?
  end

  def fetch_payload
    JenkinsXmlPayload.new(ci_build_identifier)
  end

  def webhook_payload
    JenkinsJsonPayload.new
  end
end
