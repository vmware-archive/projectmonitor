class JenkinsProjectDecorator < ProjectDecorator

  def current_build_url
    object.webhooks_enabled? ? object.parsed_url : object.ci_base_url
  end

end
