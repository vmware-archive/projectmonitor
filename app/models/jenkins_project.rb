class JenkinsProject < Project
  validates_presence_of :jenkins_base_url, :jenkins_build_name, unless: :webhooks_enabled

  alias_attribute :project_name, :jenkins_build_name
  alias_attribute :jenkins_base_url, :ci_base_url

  def self.project_specific_attributes
    ["jenkins_build_name", "ci_base_url"]
  end

  def feed_url
    "#{jenkins_base_url}/job/#{jenkins_build_name}/rssAll"
  end

  def build_status_url
    "#{jenkins_base_url}/cc.xml" if jenkins_base_url.present?
  end

  def fetch_payload
    JenkinsXmlPayload.new(jenkins_build_name)
  end

  def webhook_payload
    JenkinsJsonPayload.new
  end
end
