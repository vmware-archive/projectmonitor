class JenkinsProject < Project

  attr_accessible :jenkins_base_url, :jenkins_build_name
  validates_presence_of :jenkins_base_url, :jenkins_build_name, unless: ->(project) { project.webhooks_enabled }
  validates :jenkins_base_url, format: {with: /\Ahttps?:/i, message: "must begin with http or https"}, unless: ->(project) { project.webhooks_enabled }

  def feed_url
    "#{jenkins_base_url}/job/#{jenkins_build_name}/rssAll"
  end

  def project_name
    jenkins_build_name
  end

  def build_status_url
    return if feed_url.nil?

    url_components = URI.parse(feed_url)
    "#{url_components.scheme}://#{url_components.host}:#{url_components.port}/cc.xml"
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
