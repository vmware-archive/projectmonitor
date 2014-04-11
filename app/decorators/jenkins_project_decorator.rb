class JenkinsProjectDecorator < ProjectDecorator

  def current_build_url
    object.webhooks_enabled? ? object.parsed_url : object.jenkins_base_url
  end

end
