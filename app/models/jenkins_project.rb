class JenkinsProject < Project

  attr_accessible :jenkins_base_url, :jenkins_build_name
  validates_presence_of :jenkins_base_url, :jenkins_build_name, unless: ->(project) { project.webhooks_enabled }

  def feed_url
    "#{jenkins_base_url}/job/#{jenkins_build_name}/rssAll"
  end

  def project_name
    jenkins_build_name
  end

  def build_status_url
    return if jenkins_base_url.nil?

    "#{jenkins_base_url}/cc.xml"
  end

  def current_build_url
    if webhooks_enabled?
      parsed_url
    else
      jenkins_base_url
    end
  end

  def fetch_payload
    JenkinsXmlPayload.new(jenkins_build_name)
  end

  def webhook_payload
    JenkinsJsonPayload.new
  end

end
