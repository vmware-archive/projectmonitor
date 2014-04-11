class JenkinsProject < Project
  validates_presence_of :jenkins_base_url, :jenkins_build_name, unless: :webhooks_enabled

  alias_attribute :project_name, :jenkins_build_name

  def feed_url
    "#{jenkins_base_url}/job/#{jenkins_build_name}/rssAll"
  end

  def build_status_url
    return if jenkins_base_url.nil?

    "#{jenkins_base_url}/cc.xml"
  end

  def fetch_payload
    JenkinsXmlPayload.new(jenkins_build_name)
  end

  def webhook_payload
    JenkinsJsonPayload.new
  end
end
