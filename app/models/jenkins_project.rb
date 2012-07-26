class JenkinsProject < Project

  attr_accessible :jenkins_base_url, :jenkins_build_name
  validates  :jenkins_base_url, :jenkins_build_name, presence: true
  validates :jenkins_base_url, presence: true, format: {with: /\Ahttps?:/i, message: "must begin with http or https"}

  def feed_url
    "#{jenkins_base_url}/job/#{jenkins_build_name}/rssAll"
  end

  def project_name
    jenkins_build_name
  end

  def build_status_url
    return nil if feed_url.nil?

    url_components = URI.parse(feed_url)
    ["#{url_components.scheme}://#{url_components.host}"].tap do |url|
      url << ":#{url_components.port}" if url_components.port
      url << "/cc.xml"
    end.join
  end

  def status_url
    jenkins_base_url
  end

  def fetch_payload
    JenkinsXmlPayload.new(self)
  end

  def webhook_payload
    JenkinsJsonPayload.new(self)
  end
end
